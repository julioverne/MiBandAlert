ARCHS = armv7 arm64
TARGET = iphone:clang:8.1

include theos/makefiles/common.mk

TWEAK_NAME = MiBandAlert
MiBandAlert_CFLAGS = -fobjc-arc
MiBandAlert_FILES = MiBandAlert.xm MiBandAlertController.m MiBand/MBALCentralManager.m MiBand/MBALPeripheral.m
MiBandAlert_FRAMEWORKS = Foundation UIKit CoreBluetooth CydiaSubstrate

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	@echo "[+] Copying Files..."
	@cp -rf ./obj/obj/debug/MiBandAlert.dylib //Library/MobileSubstrate/DynamicLibraries/MiBandAlert.dylib
	@/usr/bin/ldid -S //Library/MobileSubstrate/DynamicLibraries/MiBandAlert.dylib
	@echo "DONE"
	#@killall Music
	