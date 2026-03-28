cmake_minimum_required(VERSION 3.20)
project(greeter CXX)

set(CMAKE_CXX_STANDARD 17)

# GREETER_BINDINGS_DIR is set by Nix to the wit-bindgen output path
include_directories(${GREETER_BINDINGS_DIR})

add_executable(greeter greeter.cpp)

install(TARGETS greeter DESTINATION bin)
