WORK_DIR=$(shell pwd)
TOP=chipinvaders
TAG=chipinvaders-run

PDK_ROOT ?= $(WORK_DIR)/pdk
PDK = ihp-sg13cmos5l

ARTIX7_CHIPDB = chipdb/
ADDITIONAL_SOURCES = $(wildcard src/rtl/*.sv)

TARGET ?= nexys
include $(TARGET).mk # Change this for the FPGA board you are using (e.g., TARGET=basys)

.PHONY: librelane
librelane:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --run-tag $(TAG) --overwrite config.yaml

.PHONY: librelane-nodrc
librelane-nodrc: # Run LibreLane flow without DRC checks https://github.com/IHP-GmbH/IHP-Open-PDK/issues/683
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --run-tag $(TAG) --overwrite config.yaml --skip KLayout.DRC

.PHONY: view-results
view-results:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --last-run --flow OpenInOpenROAD config.yaml

.PHONY: klayout
klayout:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --last-run --flow OpenInKLayout config.yaml