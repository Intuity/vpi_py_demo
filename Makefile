# Copyright 2020, Peter Birch, mailto:peter@lightlogic.co.uk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Locate Python library
PYTHON_LIB_DIR  ?= /usr/local/Cellar/python@3.9/3.9.1_5/Frameworks/Python.framework/Versions/3.9/lib
PYTHON_LIB_NAME ?= python3.9

# Locate Icarus VPI libary
ICARUS_LIB_DIR ?= /usr/local/Cellar/icarus-verilog/11.0/lib
ICARUS_INC_DIR ?= /usr/local/Cellar/icarus-verilog/11.0/include/iverilog
ICARUS_VPI_LIB ?= vpi

# Outputs
OUTPUT_DIR ?= output
LIB_NAME   ?= demo
LIB_EXT    ?= .vpi
OBJ_DIR    ?= $(OUTPUT_DIR)/obj
LIB_PATH   ?= $(OUTPUT_DIR)/$(LIB_NAME)$(LIB_EXT)

# Verbosity
QUIET ?= yes
ifeq ($(QUIET),yes)
  PREFIX := @
endif

# Compilation switches
CXX      ?= c++
CXX_OPTS += -O3
CXX_OPTS += -Wall
CXX_OPTS += -shared
CXX_OPTS += -std=c++11
CXX_OPTS += -fPIC
CXX_OPTS += $(shell python3 -m pybind11 --includes)
CXX_OPTS += -I$(ICARUS_INC_DIR)

# Extra flag required on macOS
ifeq ($(word 1,$(shell uname -a)),Darwin)
  CXX_OPTS += -undefined dynamic_lookup
endif

# Link switches
LINK    ?= c++
LD_OPTS += -shared
LD_OPTS += -L$(PYTHON_LIB_DIR)
LD_OPTS += -l$(PYTHON_LIB_NAME)
LD_OPTS += -L$(ICARUS_LIB_DIR)
LD_OPTS += -l$(ICARUS_VPI_LIB)

define DO_OBJ_CPP
# $(1) - Path to the .cpp file to compile
$(OBJ_DIR)/$(patsubst %.cpp,%.o,$(notdir $(1))): $(1) | $(OBJ_DIR)
	@echo "# Compiling $$(notdir $$<) -> $$(notdir $$@)"
	$(PREFIX)$(CXX) $(CXX_OPTS) -o $$@ $$<
TGT_OBJ += $(OBJ_DIR)/$(patsubst %.cpp,%.o,$(notdir $(1)))
endef
$(foreach f,$(wildcard ./*.cpp),$(eval $(call DO_OBJ_CPP,$(f))))

$(LIB_PATH): $(TGT_OBJ) | $(OUTPUT_DIR)
	@echo "# Linking objects to form $(notdir $@)"
	$(PREFIX)$(LINK) $(LD_OPTS) -o $@ $(TGT_OBJ)

$(OUTPUT_DIR) $(OBJ_DIR):
	@echo "# Creating directory $@"
	$(PREFIX)mkdir -p $@

.PHONY: build
build: $(LIB_PATH)

.PHONY: run
run: build
	@echo "# Compiling Verilog"
	$(PREFIX)iverilog -o$(OUTPUT_DIR)/run.vvp $(wildcard ./*.v)
	$(PREFIX)vvp -M$(OUTPUT_DIR) -m$(LIB_NAME) $(OUTPUT_DIR)/run.vvp

.PHONY: clean
clean:
	@echo "# Cleaning up"
	$(PREFIX)rm -rf $(OUTPUT_DIR)
