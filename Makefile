export ARDUINO_DIR ?= /usr/share/arduino
export ARDMK_DIR ?= /usr/share/arduino
export AVR_TOOLS_DIR ?= /usr
export AVRDUDE ?= /usr/bin/avrdude
export AVRDUDE_CONF ?= /etc/avrdude.conf

all: clean build upload monitor

build:
	$(MAKE) -C src/

clean:
	$(MAKE) -C src/ clean

help:
	$(MAKE) -C src/ help

monitor:
	$(MAKE) -C src/ monitor

reset:
	$(MAKE) -C src/ reset

show_boards:
	$(MAKE) -C src/ show_boards

show_submenu:
	$(MAKE) -C src/ show_submenu

upload:
	$(MAKE) -C src/ upload

.PHONY: build clean help monitor reset upload
