BUILD_DIR    = ./build
APP_NAME     = PagerCall
ARCHIVE_PATH = $(BUILD_DIR)/$(APP_NAME).xcarchive

.PHONY: build
build: clean
	xcodebuild build analyze archive \
		-destination "generic/platform=macOS" \
		-scheme $(APP_NAME) \
		-configuration Release \
		-archivePath $(ARCHIVE_PATH)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

# TODO: notary
