# qcom-fw-setup
Configurable firmware setup script for Qualcomm devices running Linux.

## Configuration
1. Create a file with a name matching one (preferably the first) of the values output by the following under `/var/lib/qcom-fw-setup` directory:
```bash
while read -d '' board; do
  echo ${board/,/-}
done </sys/firmware/devicetree/base/compatible
```
**NOTE:** `read -d` requires a `bash` shell!

2. Investigate the partition layout of your device and make notes on where to find firmware for e.g. GPU, BT, Wi-Fi and other DSPs, then
3. Write a config file for your device like this one for `oneplus-dumpling`:
```bash
# GPU + IPA
vendor:
firmware/a540_zap.{mdt,b*}                     qcom/msm8998/oneplus/a540_zap.mbn
firmware/{a530_{pfp.fw,pm4.fw},a540_gpmu.fw2}  qcom/
firmware/ipa_fws.{mdt,b*}                      qcom/msm8998/oneplus/ipa_fws.mbn

# BT
bluetooth:
image/cr{btfw21.tlv,nv21.bin}  qca/

# ADSP, SLPI, Modem, Wi-Fi, Venus
modem:
image/adsp.{mdt,b*}                                     qcom/msm8998/oneplus/adsp.mbn
image/slpi_v2.{mdt,b*}                                  qcom/msm8998/oneplus/slpi_v2.mbn
image/modem.{mdt,b*}                                    qcom/msm8998/oneplus/modem.mbn
image/venus.{mdt,b*}                                    qcom/msm8998/oneplus/venus.mbn
image/{{adspua,modemuw,slpius}.jsn,{mba,wlanmdsp}.mbn}  qcom/msm8998/oneplus/
```
The format ignores empty lines, extra whitespaces and lines beginning with a `#`.

`modem:` is a `PARTLABEL` and defines where to extract the files following it's declaration from (see `/dev/disk/by-partlabel`).

The extraction lines have a `<FILES> <TARGET>` format where bash brace expansion usage is also possible for `<FILES>`. `<FILES>` are relative to the current `PARTLABEL` filesystem root and `<TARGET>` is relative to `/lib/firmware`.

To combine a `.{mdt,b*}` files into a `.mbn` set the target as a file with this extension. In case `pil-squasher` is misssing or `SQUASH_TO_MBN=false` it will become a symlink to the `.mdt` instead.

**NOTE:** If the target is a directory make sure to end it with a `/` to make this perfectly clear for the config parser!

## See also
* [firmware-mainline-oneplus5](https://github.com/JamiKettunen/firmware-mainline-oneplus5)
* [msm-firmware-loader pmaports MR](https://gitlab.com/postmarketOS/pmaports/-/merge_requests/2431)
