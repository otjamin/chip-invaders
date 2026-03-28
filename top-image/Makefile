export IMAGE_PATH=logo/chip-invaders.png
export CELLNAME=chip-invaders
export GDS_PATH=gds/chip-invaders.gds

export PDK_ROOT=../pdk
export PDK=ihp-sg13cmos5l

export CHIP_GDS=../runs/chipinvaders-run/final/gds/top.gds
export CHIP_GDS_WITH_LOGO=gds/final-logo.gds

.PHONY: img2gds
img2gds:
	python scripts/img2gds.py --cellname $(CELLNAME) --invert --layer 134 --scale 1 --pixel-size 4 $(IMAGE_PATH) $(GDS_PATH)

.PHONY: drc
drc:
	python $(PDK_ROOT)/$(PDK)/libs.tech/klayout/tech/drc/run_drc.py --run_dir drc/ --no_density --path $(GDS_PATH)

.PHONY: klayout
klayout:
	KLAYOUT_HOME=$(PDK_ROOT)/$(PDK)/libs.tech/klayout/ klayout -e $(GDS_PATH)

.PHONY: insert_img
insert_img:
	python scripts/insert_img.py $(CHIP_GDS) $(GDS_PATH) $(CHIP_GDS_WITH_LOGO) 370 380 $(CELLNAME)

.PHONY: klayout-final
klayout-final:
	KLAYOUT_HOME=$(PDK_ROOT)/$(PDK)/libs.tech/klayout/ klayout -e $(CHIP_GDS_WITH_LOGO)