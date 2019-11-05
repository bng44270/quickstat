SHELL:=/bin/bash

define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" >> $(4)
endef

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

installpath := $(call getsetting,tmp/settings.txt,PATH) 

all:
	@echo "Directions:"
	@echo "  1) make setup"
	@echo "  2) sudo make install"
	@echo ""
	@echo "If a customization is made to the quickstat.sh file,"
	@echo "run 'sudo make updatebin' to install new quickstat.sh file"
	@echo ""
	@echo "Use 'make clean' to clear build environment"

install: etc-services
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)/bin
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)/etc
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)/lib
	find build/ -type f | while read line; do cp $$line $(call getsetting,tmp/settings.txt,PATH)$$(echo $$line | sed 's/^build//g') ; done 
	(rm /etc/xinetd.d/quickstat && ln -s $(call getsetting,tmp/settings.txt,PATH)/etc/quickstat /etc/xinetd.d/quickstat) || ln -s $(call getsetting,tmp/settings.txt,PATH)/etc/quickstat /etc/xinetd.d/quickstat
	chmod +x $(call getsetting,tmp/settings.txt,PATH)/bin/quickstat.sh

etc-services:
	[[ -z "$$(grep "$(call getsetting,tmp/settings.txt,PORT)/tcp" /etc/services)" ]] && echo -e "quickstat\t$(call getsetting,tmp/settings.txt,PORT)/tcp\t# Added by quickstat Makefile" >> /etc/services
	[[ -z "$$(grep "$(call getsetting,tmp/settings.txt,PORT)/udp" /etc/services)" ]] && echo -e "quickstat\t$(call getsetting,tmp/settings.txt,PORT)/tcp\t# Added by quickstat Makefile" >> /etc/services

updatebin: tmp/newbuild.ok
	find ./stats -type f | grep -v '.comments' | awk 'function readfile(file) { save_rs = RS; RS = "^$$"; getline tmp < file; close(file); RS = save_rs; return tmp; } { contents = readfile($$0); comments = readfile($$0 ".comments"); printf("%s\ngen%s() {\n%s}\n\n",comments,gensub(/^.*stats\//,"","g",$$0),contents); }' > build/lib/monitors.inc.sh
	rm tmp/newbuild.ok

tmp/newbuild.ok: tmp
	rm build/lib/monitors.inc.sh
	touch tmp/newbuild.ok

tmp/xinetd.ok: tmp
	@[[ -n "$$(which xinetd)" ]] && touch tmp/xinetd.ok

setup: build/etc/quickstat build/bin/quickstat.sh build/lib/monitors.inc.sh

clean:
	rm -rf tmp
	rm -rf build

build/etc/quickstat: build/etc tmp/port.ok tmp/m4.ok
	[[ ! -f build/etc/quickstat ]] && m4 -DPORT=$(call getsetting,tmp/settings.txt,PORT) -DPATH="$(call getsetting,tmp/settings.txt,PATH)" service.m4 > build/etc/quickstat

build/lib/monitors.inc.sh: build/lib
	[[ ! -f build/lib/monitors.inc.sh ]] && find ./stats -type f | grep -v '.comments' | awk 'function readfile(file) { save_rs = RS; RS = "^$$"; getline tmp < file; close(file); RS = save_rs; return tmp; } { contents = readfile($$0); comments = readfile($$0 ".comments"); printf("%s\ngen%s() {\n%s}\n\n",comments,gensub(/^.*stats\//,"","g",$$0),contents); }' > build/lib/monitors.inc.sh

build/lib: build
	mkdir -p build/lib

build/bin: build
	mkdir -p build/bin

build/etc: build
	mkdir -p build/etc

tmp/m4.ok: tmp
	@[[ -n "$$(which m4)" ]] && touch tmp/m4.ok

tmp/settings.txt: tmp
	$(call newsetting,Enter install path,PATH,/opt/quickstat,tmp/settings.txt)
	$(call newsetting,Enter port number,PORT,8080,tmp/settings.txt)

tmp/port.ok: tmp/settings.txt
	@[[ -z "$$(grep "$(call getsetting,tmp/settings.txt,PORT)" /etc/services)" ]] && touch tmp/port.ok

build/bin/quickstat.sh: build/bin
	[[ ! -f build/bin/quickstat.sh ]] && (echo "define(\`MONLIST',\`" ; find ./stats -type f | grep -v '.comments$$' | sed 's/^\.\/stats\///g;s/^/gen/g;s/$$/\nprintf ","/g' | sed '$$ d' ; echo "')" ; echo -n "define(\`RESLIST',\`" ; find ./stats | sed 's/^\.//g' | tr '\n' ' ' ; echo "')" ; cat quickstat.m4) | m4 -DROOTDIR="$(call getsetting,tmp/settings.txt,PATH)" | grep -v '^[ \t]*$$' > build/bin/quickstat.sh

build:
	[[ ! -d ./build ]] && mkdir build

tmp:
	[[ ! -d tmp ]] && mkdir tmp
