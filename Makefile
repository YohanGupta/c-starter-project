# Delete the default suffixes (otherwise visible in 'make -d')
.SUFFIXES:

# Cancel source control implicit rules (otherwise visible in 'make -d')
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%

# Folders used
## source files expected here
SRC_DIR = src
## contains executables we build
BIN_DIR = bin
## intermediate build folder e.g. for object files and dependency files
INT_DIR = int
## temp folder
TMP_DIR = tmp

# TODO: Change executable name
TARGET = main.out

# Compiler flags
CXX = g++
CC = gcc
## -MMD creates dependency list, but ignores system includes
## -MF specifies where to create the dependency file name
## -MP creates phony targets for headers (deals with deleted headers after
##  obj file has been compiled)
## -MT specifies the dependency target (path qualified obj file name)
DEP_FLAGS = -MT $@ -MMD -MP -MF $(@:.o=.d)
# STD_FLAGS = --std=c++14 -pthread -fno-rtti -g
DEBUG_FLAGS = -g
WARN_FLAGS = -Wall -Werror
# CXXFLAGS = $(STD_FLAGS) $(DEP_FLAGS) $(WARN_FLAGS)
CCFLAGS = $(DEBUG_FLAGS) $(DEP_FLAGS) $(WARN_FLAGS)
LDFLAGS = $(WARN_FLAGS)

# Things to build
BIN_TARGET = $(BIN_DIR)/$(TARGET)
C_FILES := $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES := $(C_FILES:$(SRC_DIR)/%.c=$(INT_DIR)/%.o)
DEP_FILES := $(C_FILES:$(SRC_DIR)/%.c=$(INT_DIR)/%.d)

# Rules on how to build

## To build all 'make'
.DEFAULT: all

.PHONY: all clean run

all: $(BIN_TARGET)

## Compilation rule (dependency on .d file ensures that if the .d file
## is deleted, the obj file is created again in case a header is changed)
$(OBJ_FILES): $(INT_DIR)/%.o: $(SRC_DIR)/%.c $(INT_DIR)/%.d | $(INT_DIR)
	$(CC) $(CCFLAGS) -c -o $@ $<

## Linkage rule
$(BIN_TARGET): $(OBJ_FILES) | $(BIN_DIR)
	$(CC) $(LDFLAGS) -o $@ $^

## Folders creation
$(BIN_DIR) $(INT_DIR):
	mkdir -p $@

## To clean and build run 'make clean && make'
clean:
	rm -rf $(BIN_DIR) $(INT_DIR) $(TMP_DIR)

## To build and run the program 'make run'
run: all
	$(BIN_TARGET)

test:
	@echo $(C_FILES)
	@echo $(OBJ_FILES)
	@echo $(DEP_FILES)
	@echo $(BIN_TARGET)

## Do not fail when dependency file is deleted (it is required by the compile
## rule)
$(DEP_FILES): $(INT_DIR)/%.d: ;

# Include dependency files (ignore them if missing)
-include $(DEP_FILES)