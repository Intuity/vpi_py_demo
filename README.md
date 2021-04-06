# Calling Python from Verilog via VPI
This is a demonstration of how to call a routine in Python from Verilog using a C++ VPI hook intermediary layer.

## Configuration
Before compiling, make sure to update the following variables in `Makefile`:

 * `PYTHON_LIB_DIR` - should point at the directory containing the `libpython` shared library for your installation.
 * `PYTHON_LIB_NAME` - should be the name of your Python library (excluding the `lib` prefix and `.so`/`.dylib` suffix).
 * `ICARUS_LIB_DIR` - should point at the directory containing `libvpi.a`, provided with Icarus Verilog.
 * `ICARUS_INC_DIR` - should point at the directory containing header files for Icarus Verilog (specifically `vpi_user.h`).
 * `ICARUS_VPI_LIB` - should be the name of the VPI library provided with Icarus Verilog (excluding the `lib` prefix and `.a`/`.so` suffix).

## To Run the Demo
Once you've adjusted the configuration as above, execute `make run` to run the demo:

```bash
$> make run
# Creating directory output/obj
# Compiling demo.cpp -> demo.o
# Linking objects to form demo.vpi
# Compiling Verilog
About to call C++ from Verilog through VPI
About to call Python from C++ via pybind11
This is from Python - calling C++: 3
```

## What's Going on Here?
The following steps are happening:

 * In `demo.v` a call is made to a `$demo` system task.
 * When `$demo` is called, it actually executes a VPI function from `demo.cpp` called `trampoline_calltf`.
 * The trampoline function then calls `do_something` - which is a function imported from the `demo.py`.
 * The `do_something` function in `demo.py` then calls back to a function exposed from C++ called `add` (see `demo.cpp` lines 19-22) again using pybind11.
