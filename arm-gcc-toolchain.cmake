# CMake Toolchain file for ARM GCC (arm-none-eabi)

# 1. --- 系统和处理器信息 ---
#    告诉CMake我们正在为嵌入式系统进行交叉编译
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# 2. --- 工具链程序 ---
#    在你的系统中查找ARM GCC工具链的可执行文件
#    确保 arm-none-eabi-gcc 等工具在你的系统PATH中，或者在这里指定完整路径
find_program(CMAKE_C_COMPILER NAMES arm-none-eabi-gcc)
find_program(CMAKE_CXX_COMPILER NAMES arm-none-eabi-g++)
find_program(CMAKE_AR NAMES arm-none-eabi-ar)
find_program(CMAKE_OBJCOPY NAMES arm-none-eabi-objcopy)
find_program(CMAKE_OBJDUMP NAMES arm-none-eabi-objdump)
find_program(CMAKE_SIZE NAMES arm-none-eabi-size)

# 检查编译器是否找到
if(NOT CMAKE_C_COMPILER)
    message(FATAL_ERROR "arm-none-eabi-gcc not found. Please add it to your PATH or specify the path.")
endif()

# 3. --- 默认编译标志 ---
#    这些是所有库版本都会用到的基础标志
#    -O3: 最高等级的优化
#    -g:  生成调试信息
#    -ffunction-sections & -fdata-sections: 优化最终链接时的大小
set(COMMON_FLAGS "-O3 -g -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS_INIT "${COMMON_FLAGS}" CACHE STRING "Initial C flags" FORCE)
set(CMAKE_CXX_FLAGS_INIT "${COMMON_FLAGS}" CACHE STRING "Initial CXX flags" FORCE)
set(CMAKE_ASM_FLAGS_INIT "${COMMON_FLAGS}" CACHE STRING "Initial ASM flags" FORCE)

# --- !!! 错误修复 !!! ---
# 添加 -nostdlib 标志来告诉链接器在进行编译器测试时不链接标准库。
# 这可以避免在裸机交叉编译环境中出现 "undefined reference to `_exit`" 的错误。
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,--gc-sections -nostdlib" CACHE STRING "Initial linker flags" FORCE)

# 4. --- 设置查找目标 ---
#    这会影响find_package, find_library等命令的搜索行为
#    设置为NEVER意味着只在工具链指定的sysroot中查找，不在主机系统上查找
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

