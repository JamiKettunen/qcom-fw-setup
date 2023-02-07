# qcom-fw-setup
Configurable firmware setup script for Qualcomm devices running Linux.

## Configuration
1. Create a file with a name matching one (preferably the first) of the values output by the following under `/etc/qcom-fw-setup` directory:
```sh
tr '\0,' '\n-' < /proc/device-tree/compatible
```
This is going to be the config file for your device.

2. Investigate the partition layout of your device and make notes on where to find firmware for e.g. GPU, BT, Wi-Fi and other DSPs, then
3. Write a config file for your device like this one for `oneplus-dumpling`:
```bash
WLAN_DRIVER="ath10k"
WLAN_HW="WCN3990/hw1.0"
WLAN_FW_API=5
WLAN_FW_FEATURES="wowlan,mgmt-tx-by-ref,non-bmi,single-chan-info-per-channel"
WLAN_FW_FLAGS=(--set-wmi-op-version="tlv" --set-htt-op-version="tlv")
SQUASH_TO_MBN=true

process_fw() {
	# GPU + IPA
	par vendor
	fw firmware/a540_zap.{mdt,b*}                    qcom/msm8998/oneplus/a540_zap.mbn
	fw firmware/{a530_{pfp.fw,pm4.fw},a540_gpmu.fw2} qcom/
	fw firmware/ipa_fws.{mdt,b*}                     qcom/msm8998/oneplus/ipa_fws.mbn

	# BT
	par bluetooth
	fw image/cr{btfw21.tlv,nv21.bin} qca/

	# ADSP, SLPI, Modem, Wi-Fi, Venus
	par modem
	fw image/adsp.{mdt,b*}                                    qcom/msm8998/oneplus/adsp.mbn
	fw image/slpi_v2.{mdt,b*}                                 qcom/msm8998/oneplus/slpi_v2.mbn
	fw image/modem.{mdt,b*}                                   qcom/msm8998/oneplus/modem.mbn
	fw image/venus.{mdt,b*}                                   qcom/msm8998/oneplus/venus.mbn
	fw image/{{adspua,modemuw,slpius}.jsn,{mba,wlanmdsp}.mbn} qcom/msm8998/oneplus/
	fw image/bdwlan*.*                                        bdwlan/
}
```

`par modem` sets `PARTLABEL=modem` and defines where to extract the files following it's declaration from (see `/dev/disk/by-partlabel`).

The extraction lines have a `fw <FILES> <TARGET>` format where bash brace expansion usage is also possible for `<FILES>`. `<FILES>` are relative to the current `PARTLABEL` filesystem root and `<TARGET>` (may be `.`) is relative to `/lib/firmware/`. Optional arguments to `fw` include:
- `-o`: Don't overwrite pre-existing files, such as those from e.g. `linux-firmware`
- `-a`: Allow failures in copying files without a fatal error

To combine a `.{mdt,b*}` files into a `.mbn` set the target as a file with this extension as well as `SQUASH_TO_MBN=true`. In case `pil-squasher` is misssing or `SQUASH_TO_MBN=false` it will become a symlink to the `.mdt` instead.

To generate WLAN files (for e.g. `ath10k`) you need to add the `bdwlan*.*` FW into `bdwlan/` in your `process_fw()` and set the `WLAN_*` options accordingly for your SoC.

**NOTE:** If the target is a directory make sure to end it with a `/` to make this perfectly clear for the config parser!

## See also
* [firmware-mainline-oneplus5](https://github.com/JamiKettunen/firmware-mainline-oneplus5)
* [msm-firmware-loader pmaports MR](https://gitlab.com/postmarketOS/pmaports/-/merge_requests/2431)
* [Mobian's droid-juicer](https://gitlab.com/mobian1/droid-juicer)
* [qca-swiss-army-knife](https://github.com/qca/qca-swiss-army-knife)
