# CMake build script for CMSIS-DSP library
cmake_minimum_required(VERSION 3.15)
project(CMSIS_DSP_Builder C)

# --- 1. 搜集所有源文件 ---
# 递归地查找Source目录下所有的.c文件
file(GLOB_RECURSE DSP_SOURCES "Source/*.c")

# --- 2. 定义包含目录 ---
# 添加头文件搜索路径
include_directories(
    "${CMAKE_CURRENT_SOURCE_DIR}/Include"
    "${CMAKE_CURRENT_SOURCE_DIR}/Core/Include" # <--- !!! 错误修复：添加CMSIS-Core头文件路径 !!!
    "${CMAKE_CURRENT_SOURCE_DIR}/PrivateInclude"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/CommonTables"
)

# --- 3. 定义一个函数来创建不同版本的库 ---
#    这个函数避免了大量重复的代码
#    参数:
#    - target_name: 库的目标名称 (例如 "arm_cortexM7lfdp_math")
#    - compile_definitions: 传递给编译器的宏定义 (例如 "ARM_MATH_CM7;__FPU_PRESENT=1")
#    - compile_options: 传递给编译器的选项 (例如 "-mcpu=...")
function(add_cmsis_dsp_variant target_name compile_definitions compile_options)
    
    # 创建一个静态库目标
    add_library(${target_name} STATIC ${DSP_SOURCES})

    # 为这个特定的库目标设置宏定义
    target_compile_definitions(${target_name} PRIVATE ${compile_definitions})

    # 为这个特定的库目标设置编译选项
    target_compile_options(${target_name} PRIVATE ${compile_options})

    # 设置输出属性：
    # - OUTPUT_NAME: 设置最终的文件名（不含前缀和后缀）
    # - SUFFIX: 强制将文件后缀设置为 .a
    set_target_properties(${target_name} PROPERTIES
        OUTPUT_NAME "${target_name}"
        SUFFIX ".a"
    )

    message(STATUS "Configured target: ${target_name}.a")
endfunction()


# --- 4. 依次创建所有6个版本的库 ---
#    我们在这里调用上面定义的函数6次，每次传入不同的配置

# 目标 1: Cortex-M7, 小端序, 双精度浮点
add_cmsis_dsp_variant(
    arm_cortexM7lfdp_math
    "ARM_MATH_CM7;__FPU_PRESENT=1;ARM_MATH_LOOPUNROLL"
    "-mcpu=cortex-m7;-mthumb;-mlittle-endian;-mfloat-abi=hard;-mfpu=fpv5-d16"
)

# 目标 2: Cortex-M7, 大端序, 双精度浮点
add_cmsis_dsp_variant(
    arm_cortexM7bfdp_math
    "ARM_MATH_CM7;__FPU_PRESENT=1;ARM_MATH_LOOPUNROLL"
    "-mcpu=cortex-m7;-mthumb;-mbig-endian;-mfloat-abi=hard;-mfpu=fpv5-d16"
)

# 目标 3: Cortex-M7, 小端序, 单精度浮点
add_cmsis_dsp_variant(
    arm_cortexM7lfsp_math
    "ARM_MATH_CM7;__FPU_PRESENT=1;ARM_MATH_LOOPUNROLL"
    "-mcpu=cortex-m7;-mthumb;-mlittle-endian;-mfloat-abi=hard;-mfpu=fpv5-sp-d16"
)

# 目标 4: Cortex-M7, 大端序, 单精度浮点
add_cmsis_dsp_variant(
    arm_cortexM7bfsp_math
    "ARM_MATH_CM7;__FPU_PRESENT=1;ARM_MATH_LOOPUNROLL"
    "-mcpu=cortex-m7;-mthumb;-mbig-endian;-mfloat-abi=hard;-mfpu=fpv5-sp-d16"
)

# 目标 5: Cortex-M7, 小端序, 无浮点单元 (软浮点)
add_cmsis_dsp_variant(
    arm_cortexM7l_math
    "ARM_MATH_CM7;ARM_MATH_LOOPUNROLL"
    "-mcpu=cortex-m7;-mthumb;-mlittle-endian;-mfloat-abi=soft"
)

# 目标 6: Cortex-M7, 大端序, 无浮点单元 (软浮点)
add_cmsis_dsp_variant(
    arm_cortexM7b_math
    "ARM_MATH_CM7;ARM_MATH_LOOPUNROLL"
    "-mcpu=cortex-m7;-mthumb;-mbig-endian;-mfloat-abi=soft"
)

# --- 5. 安装规则 (可选) ---
#    这个部分定义了如果你运行 "install" 命令，文件会被复制到哪里
#    这对于创建可分发的SDK非常有用
install(TARGETS 
    arm_cortexM7lfdp_math
    arm_cortexM7bfdp_math
    arm_cortexM7lfsp_math
    arm_cortexM7bfsp_math
    arm_cortexM7l_math
    arm_cortexM7b_math
    ARCHIVE DESTINATION lib)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/Include/" DESTINATION include)
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/Core/Include/" DESTINATION include/core)
