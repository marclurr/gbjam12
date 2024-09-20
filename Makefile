NAME := gbjam12

SRC_DIR  := ./src
BUILD_DIR := ./build
WEB_DIR := $(BUILD_DIR)/web

ARCHIVE := ./$(NAME).love
WEB_ARCHIVE := ./$(NAME)-web.zip
COMPAT = -c

$(WEB_ARCHIVE): $(WEB_DIR)
	cd $(WEB_DIR); \
	zip -r ../../$(WEB_ARCHIVE) *

$(WEB_DIR): $(ARCHIVE)
	love.js $(COMPAT) -m 32000000 -t $(NAME) $(ARCHIVE) $(WEB_DIR)

$(ARCHIVE): $(BUILD_DIR)
	cd $(BUILD_DIR); \
	zip -r ../$(ARCHIVE) *

$(BUILD_DIR): clean
	mkdir -p $(BUILD_DIR) $(BUILD_DIR)/data/gfx $(BUILD_DIR)/data/tilemaps $(BUILD_DIR)/data/sfx $(BUILD_DIR)/data/music; \
	rsync -vr $(SRC_DIR)/* $(BUILD_DIR); \
	./scripts/build-gfx.sh --now; \
	./scripts/build-tilemaps.sh; \
	rsync -vr raw-assets/sfx $(BUILD_DIR)/data; \
	rsync -vr raw-assets/music $(BUILD_DIR)/data; \



clean:
	rm -rf $(BUILD_DIR) $(ARCHIVE) $(WEB_ARCHIVE)

run: $(BUILD_DIR)
	love build

serve: $(WEB_DIR)
	cd $(WEB_DIR); \
	python3 -m http.server