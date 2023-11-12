# //toolchain:mingw_cc_toolchain_config.bzl
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
    "artifact_name_pattern"
)

# Define mingw toolchain implementation for new toolchain rule
def _impl(ctx):
    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/bin/x86_64-w64-mingw32-gcc",
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/x86_64-w64-mingw32-ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/x86_64-w64-mingw32-ar",
        ),
        tool_path(
            name = "cpp",
            path = "/usr/bin/x86_64-w64-mingw32-cpp",
        ),
        tool_path(
            name = "gcov",
            path = "/usr/bin/x86_64-w64-mingw32-gcov",
        ),
        tool_path(
            name = "nm",
            path = "/usr/bin/x86_64-w64-mingw32-nm",
        ),
        tool_path(
            name = "objdump",
            path = "/usr/bin/x86_64-w64-mingw32-objdump",
        ),
        tool_path(
            name = "strip",
            path = "/usr/bin/x86_64-w64-mingw32-strip",
        ),
    ]

    features = [
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_link_executable,
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-lstdc++",
                            ],
                        ),
                    ]),
                ),
            ],
        ),
    ]

    # Tell bazel that the output will different extensions than usually
    # seen in linux
    artifact_name_patterns = [
        artifact_name_pattern(
            category_name = "object_file",
            prefix = "",
            extension = ".obj",
        ),
        artifact_name_pattern(
            category_name = "static_library",
            prefix = "",
            extension = ".lib",
        ),
        artifact_name_pattern(
            category_name = "alwayslink_static_library",
            prefix = "",
            extension = ".lo.lib",
        ),
        artifact_name_pattern(
            category_name = "executable",
            prefix = "",
            extension = ".exe",
        ),
        artifact_name_pattern(
            category_name = "dynamic_library",
            prefix = "",
            extension = ".dll",
        ),
        artifact_name_pattern(
            category_name = "interface_library",
            prefix = "",
            extension = ".if.lib",
        ),
    ]


    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        cxx_builtin_include_directories = [
            "/usr/x86_64-w64-mingw32/include",
            "/usr/x86_64-w64-mingw32/lib",
            "/usr/lib/gcc/x86_64-w64-mingw32/10-win32/include",
            "/usr/lib/gcc/x86_64-w64-mingw32/10-win32/include/c++",
            "/usr/lib/gcc/x86_64-w64-mingw32/10-win32/include-fixed",
            "/usr/lib/gcc/x86_64-w64-mingw32/9.3-win32/include",
            "/usr/lib/gcc/x86_64-w64-mingw32/9.3-win32/include/c++",
            "/usr/lib/gcc/x86_64-w64-mingw32/9.3-win32/include-fixed",
            "/usr/share/mingw-w64/include",
            "/usr/include"
        ],
        toolchain_identifier = "mingw-toolchain",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = "mingw",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        # Set the artifact_name_patterns attribute.
        artifact_name_patterns = artifact_name_patterns,
    )

# Set mingw Toolchain Rule
mingw_cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)