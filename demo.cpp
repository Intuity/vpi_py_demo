// Copyright 2020, Peter Birch, mailto:peter@lightlogic.co.uk
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdio.h>
#include <pybind11/embed.h>
#include <vpi_user.h>

PYBIND11_EMBEDDED_MODULE(cpp_module, m) {
    m.def("add", [](int i, int j) {
        return i + j;
    });
}

static pybind11::scoped_interpreter guard{};
static pybind11::object py_module    = pybind11::module_::import("demo");
static pybind11::object do_something = py_module.attr("do_something");

static int trampoline_compiletf(char * dummy) {
    return 0;
}

static int trampoline_calltf(char * dummy) {
    printf("About to call Python from C++ via pybind11\n");
    do_something();
    return 0;
}

void demo_register() {
    s_vpi_systf_data tf_data;
    tf_data.type      = vpiSysTask;
    tf_data.tfname    = "$demo";
    tf_data.compiletf = trampoline_compiletf;
    tf_data.calltf    = trampoline_calltf;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    demo_register,
    0
};
