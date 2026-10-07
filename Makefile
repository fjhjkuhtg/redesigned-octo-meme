ARCHS = arm64
TARGET = iphone:clang:latest:14.0
include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EniCore
EniCore_FILES = EniCore.mm
EniCore_FRAMEWORKS = Foundation
include $(THEOS)/makefiles/library.mk
