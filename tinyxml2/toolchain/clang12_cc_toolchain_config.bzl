# //toolchain:clang12_cc_toolchain_config.bzl
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
)

# Define toolchain implementation
def _impl(ctx):
    # Define the paths to the compiler and linker tools for the Clang-12 toolchain
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/bin/clang-12",
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/ar",
        ),
        tool_path(
            name = "cpp",
            path = "/usr/bin/clang-cpp-12",
        ),
        tool_path(
            name = "gcov",
            path = "/usr/bin/gcov",
        ),
        tool_path(
            name = "nm",
            path = "/usr/bin/nm",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/bin/objdump",
        ),
        tool_path(
            name = "strip",
            path = "/usr/bin/strip",
        ),
    ]

    # Deinfe the compiler/liker options
    features = [
        feature(
            # Prefer the libc++ to libstdc++ library
            name = "use_libc++_as_stdlib",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_compile,
                    ],
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-stdlib=libc++",
                                "-fPIC",
                            ],
                        ),
                    ]),
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_link_executable,
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-lc++",
                            ],
                        ),
                    ]),
                ),
            ],
        ),
        feature(
            name = "dynamic_linking_mode",
            enabled = True,
            )
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        cxx_builtin_include_directories = [
            "/usr/lib/llvm-12/include",
            "/usr/lib/llvm-12/lib/clang/12.0.1/share",
            "/usr/lib/llvm-12/lib/clang/12.0.0/share",
            "/usr/lib/llvm-12/lib/clang/12.0.1/include",
            "/usr/lib/llvm-12/lib/clang/12.0.0/include",
            "/usr/include",
            "/usr/include/c++/11",
            "/usr/local/include",
        ],
        toolchain_identifier = "clang12-toolchain",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

# Set Clang-12 Toolchain Rule
clang12_cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)