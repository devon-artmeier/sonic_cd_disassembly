# ------------------------------------------------------------------------------
# Definitions
# ------------------------------------------------------------------------------

BUILD_ROOT_PATH := build

ifeq ($(OS),Windows_NT)
NULL            := nul 2> nul
else
NULL            := /dev/null
endif

export BUILD_ROOT_PATH
export NULL

# ------------------------------------------------------------------------------
# Reserved rules
# ------------------------------------------------------------------------------

.PHONY: all japan usa europe clean

# ------------------------------------------------------------------------------
# Compile for all regions
# ------------------------------------------------------------------------------

all:
	@$(MAKE) -f make.rules --no-print-directory REGION=JAPAN REGION_FOLDER=japan
	@$(MAKE) -f make.rules --no-print-directory REGION=USA REGION_FOLDER=usa
	@$(MAKE) -f make.rules --no-print-directory REGION=EUROPE REGION_FOLDER=europe

# ------------------------------------------------------------------------------
# Compile for Japanese Sega CD
# ------------------------------------------------------------------------------

japan:
	@$(MAKE) -f make.rules --no-print-directory REGION=JAPAN REGION_FOLDER=japan

# ------------------------------------------------------------------------------
# Compile for American Sega CD
# ------------------------------------------------------------------------------

usa:
	@$(MAKE) -f make.rules --no-print-directory REGION=USA REGION_FOLDER=usa

# ------------------------------------------------------------------------------
# Compile for European Sega CD
# ------------------------------------------------------------------------------

europe:
	@$(MAKE) -f make.rules --no-print-directory REGION=EUROPE REGION_FOLDER=europe

# ------------------------------------------------------------------------------
# Clean
# ------------------------------------------------------------------------------

clean:
ifneq ($(wildcard $(BUILD_ROOT_PATH)),)
	@sh -c 'rm -rf $(BUILD_ROOT_PATH)' > $(NULL) || rmdir /s /q "$(subst /,\,$(BUILD_ROOT_PATH))"
endif

# ------------------------------------------------------------------------------