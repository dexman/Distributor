TEMPORARY_FOLDER?=/tmp/Distributor.dst
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

XCODEFLAGS=-project 'Distributor.xcodeproj' -target 'Distributor' DSTROOT=$(TEMPORARY_FOLDER)

OUTPUT_FRAMEWORK=DistributorKit.framework

BUILT_BUNDLE=$(TEMPORARY_FOLDER)/Applications/distributor.app
DISTRIBUTORKIT_BUNDLE=$(BUILT_BUNDLE)/Contents/Frameworks/$(OUTPUT_FRAMEWORK)
DISTRIBUTOR_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/distributor

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin

.PHONY: all clean test

all:
	$(BUILD_TOOL) $(XCODEFLAGS) build

test: clean
	$(BUILD_TOOL) $(XCODEFLAGS) test

clean:
	rm -rf "$(TEMPORARY_FOLDER)"
	$(BUILD_TOOL) $(XCODEFLAGS) clean

installables: clean
	$(BUILD_TOOL) $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	mv -f "$(DISTRIBUTORKIT_BUNDLE)" "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	mv -f "$(DISTRIBUTOR_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/distributor"
	rm -rf "$(BUILT_BUNDLE)"

prefix_install: installables
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -Rf "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)" "$(PREFIX)/Frameworks/"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/distributor" "$(PREFIX)/bin/"
	install_name_tool -add_rpath "@executable_path/../Frameworks/$(OUTPUT_FRAMEWORK)/Versions/Current/Frameworks/"  "$(PREFIX)/bin/distributor"
