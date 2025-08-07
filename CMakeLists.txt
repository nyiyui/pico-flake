cmake_minimum_required(VERSION 3.13...3.27)

# set board here or via CLI args
# set(PICO_PLATFORM rp2350)
# set(PICO_BOARD pico2_w)

include(pico_sdk_import.cmake) # note: this must happen before project()

project(my_project)
set(CMAKE_C_STANDARD 11)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
pico_sdk_init()

if (PICO_SDK_VERSION_STRING VERSION_LESS "2.1.0")
    message(FATAL_ERROR "Raspberry Pi Pico SDK version 2.1.0 (or later) required. Your version is ${PICO_SDK_VERSION_STRING}")
endif()

# rest of your project
add_executable(main
    main.c
)

# pull in common dependencies
target_link_libraries(main pico_stdlib hardware_pio pico_stdio_uart)

pico_enable_stdio_usb(main 1)
pico_enable_stdio_uart(main 0)

# create map/bin/hex file etc.
pico_add_extra_outputs(main)
