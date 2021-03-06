TARGET_EXEC ?= plato.html

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src


CC=emcc

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.s)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

CFLAGS=-O3 --closure 1 -g0 -s USE_SDL=2 -s USE_SDL_NET=2 -s WEBSOCKET_URL=wss://js.irata.online:2005
LDFLAGS=-g0 -s WASM=0 -s USE_SDL=2 -s USE_SDL_NET=2 --shell-file src/shell.html -s WEBSOCKET_URL=wss://js.irata.online:2005 -s EXPORTED_FUNCTIONS='["_main","_keyboard_out"]'

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS ?= $(INC_FLAGS) -MMD -MP

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)
	uglifyjs build/plato.js --output build/plato-min.js

# assembly
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p
