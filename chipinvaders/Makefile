WORK_DIR=$(shell pwd)
TOP=chipinvaders
TAG=chipinvaders-run

PDK_ROOT ?= $(WORK_DIR)/pdk
PDK = ihp-sg13cmos5l

ADDITIONAL_SOURCES = $(wildcard src/rtl/*.sv)

include nexys.mk # Change this for the FPGA board you are using

.PHONY: librelane
librelane:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --run-tag $(TAG) --overwrite config.yaml

.PHONY: view-results
view-results:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --last-run --flow OpenInOpenROAD config.yaml

.PHONY: klayout
klayout:
	PDK_ROOT=$(PDK_ROOT) PDK=$(PDK) librelane --manual-pdk --last-run --flow OpenInKLayout config.yaml