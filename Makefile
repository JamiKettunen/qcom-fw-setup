PREFIX ?= /usr
FW_DIR ?= /lib/firmware
CFG_DIR ?= /etc/qcom-fw-setup
QCA_SAK_DIR ?= /var/lib/qcom-fw-setup/qca-swiss-army-knife

build: qcom-fw-setup
qcom-fw-setup: qcom-fw-setup.sh.in
	sed -e "s|@FW_DIR@|$(FW_DIR)|" \
	    -e "s|@CFG_DIR@|$(CFG_DIR)|" \
	    -e "s|@QCA_SAK_DIR@|$(QCA_SAK_DIR)|" \
	    qcom-fw-setup.sh.in > qcom-fw-setup

check:
	shellcheck qcom-fw-setup

install-all: install install-qca-sak
install:
	install -Dm755 qcom-fw-setup -t $(DESTDIR)$(PREFIX)/bin
	if [ -d configs ]; then \
		mkdir -p $(DESTDIR)$(CFG_DIR); \
		cp -a configs/* $(DESTDIR)$(CFG_DIR); \
	fi

install-qca-sak:
	git clone https://github.com/qca/qca-swiss-army-knife.git $(QCA_SAK_DIR)

clean:
	rm -f qcom-fw-setup
