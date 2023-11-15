# woven_builder_test

This repository contains an updated version of tinyxml2 that utilizes the Bazel build system. You can build and test the library using the provided Dockerfile. The enhanced build system includes the following features:

1. Creation of a stand-alone shared library with a header file for tinyxml2.
2. Compilation of the test executable for tinyxml2 with the ability to run tests using Bazel.
3. Default compilation with GCC.
4. Support for a Clang-12 toolchain.
5. Support for a Mingw toolchain to cross-compile for Windows from Linux.
6. Added AddressSanitizer support.
7. Added ThreadSanitizer support.
8. Created a test file (`xmltest_memleak.cpp`) with an injected memory leak to confirm AddressSanitizer functionality (refer to note in Compile and Test Instructions - Step 2 - Memory Leak Test).
9. Creating a CI Pipeline in the form of a Github Actions file

## Files Added:
- Dockerfile
- Dockerfile_GithubActions
- README.md (this file)
- .gitignore
- ./github/workflows/docker_container_workflow.yml
- tinyxml2/WORKSPACE.bazel
- tinyxml2/.bazelrc
- tinyxml2/toolchain/BUILD.bazel
- tinyxml2/toolchain/clang12_cc_toolchain_config.bazel
- tinyxml2/toolchain/mingw_cc_toolchain_config.bazel
- tinyxml2/xmltest_memleak.cpp

## Docker Environment Setup
1. Open a terminal window at the directory of `brian.lichtman`.
2. Build the Docker container.
   - Command: `docker build -t test-env .`
   - This command may need to be run with `sudo` depending on your environment.
3. Wait for the Docker container to build. You can ignore the debconf message as it is not a true error.
4. Start the Docker container.
   - Command: `docker run -it --rm -v $PWD/tinyxml2:/work test-env`
   - This command may need to be run with `sudo` depending on your environment.
   - This command will set up the docker contianer allowing for terminal interaction from the user within the docker container. Additionally, this will mount the tinyxml2 directory to a working directory within the docker container such that compilation and excution can be performed.
5. To exit the Docker container, run the command `exit`.
6. To re-enter the existing Docker container, repeat step 4.
7. To remove the Docker image when finished, run the following command:
   - Command: `docker rmi test-env`
   - This command may need to be run with `sudo` depending on your environment.

## Compile and Test Instructions
*Make sure you have completed the Docker Environment Setup steps and are at a terminal window sitting at the directory `/work`.*

1. Build the project.
   - Command: `bazel build //...`
     - This will build using the default GCC compiler.
     - You can also specify a toolchain to switch to Clang-12 or Mingw for cross-compilation (refer to commands below).
     - To build with Clang-12: `bazel build --config=clang12_config //...`
     - To build with Mingw: `bazel build --config=mingw_config //...`
   - To build with ThreadSanitizer (tsan) or AddressSanitizer (asan) with either GCC or Clang:  
     *Note, this will not work with Mingw for Windows as it is not currently compatible out of the box. Additionally, note that asan and tsan cannot be run together as this isn't allowed by these libraries.*
     - To build with asan using GCC: `bazel build --config=asan //...`
     - To build with tsan using GCC: `bazel build --config=tsan //...`
     - To build with asan using Clang: `bazel build --config=clang12_config --config=asan //...`
     - To build with tsan using Clang: `bazel build --config=clang12_config --config=tsan //...`

2. Run the test application from tinyxml2.
   - Command: `bazel test //:xmltest`
     - To run with a specific configuration, append the `--config` flag. Example:
       - Command: `bazel test --config=clang12_config //:xmltest`
   - This should produce an output saying the test passed in 0.1s. There will be a warning because the test takes more time than bazel expects since the test code wasn't written by the tinyxml2 authors to keep bazels timeing requirements in mind.
   - The actual test outputs can be found by running the `cat` command on the output log or XML file.
     - Command: `cat /work/bazel-testlogs/xmltest/test.log`
     - Command: `cat /work/bazel-testlogs/xmltest/test.xml`
   - To run the test with the Clang, tsan or asan, append the `--config` flag(s) as described above in Step 1. Example:
     - Command: `bazel test --config=clang12_config --config=asan //:xmltest`

   ### Memory Leak Test
   *Note that since there are no detectible memory leaks in tinyxml2's test program and since tinyxml2 is not threaded, no errors will be reported. However, I did create a modified version of tinyxml2/xmltest.cpp called tinyxml2/xmltest_memleak.cpp. This version modifiesthe XMLTest function to malloc some memory which is never deleted every time the test function is called which will cause errors to show so we can see asans is working. I did not however create a threading bug as adding multithreading seemed considerably beyond the scope of this exercise.*
   - Run the test file with a memory leak with asan.
     - Command: `bazel test --config=asan //:xmltest_memleak`
   - This time there will be an error output as leaks are detected. Bazel will give advice to check the log file for the details of the error.
   - The test output files can be checked using the following commands (the directory will be different from the standard test executable):
     - `cat /work/bazel-testlogs/xmltest_memleak/test.log`
     - `cat /work/bazel-testlogs/xmltest_memleak/test.xml`
   - The output file will be full of memory leaks detected by asan.

## Clean Instructions
1. Run the following command from the `/work` directory to clean the workspace.
   - Command: `bazel clean`

## Expected Outputs
The directory `bazel-bin` will contain the compiled outputs. Given the time contraints of this challenge, I decided not to allocate time to learning the file management aspects of the bazel build system so instead I will just list how to find the approprate outputs of each build. Also, I could not figure out why when using a toolchain, bazel is doing static compilation of the library which is why I forced a shared library output target. Based on the documentation, it looks like telling it to not link statically should cause dynamic linking, but bazel appears to ignore this when I use a toolchain.

### GCC/Clang Build Outputs
**Library Project:**
- Folders: 
  - `/work/bazel-bin/libtinyxml2_shared.so.runfiles/__main__/`
- Files:
  - `tinyxml2.h`
  - `tinyxml2_shared.so`

**Executable Project:**
- Folders:
  - Standard Test:
    - `/work/bazel-bin/xmltest.runfiles/__main__/`
    - `/work/bazel-bin/xmltest.runfiles/__main__/resources/`  (resources needed for testing)
  - Injected Memory Leak Test:
    - `/work/bazel-bin/xmltest_memleak.runfiles/__main__/`
    - `/work/bazel-bin/xmltest_memleak.runfiles/__main__/resources/`  (resources needed for testing)
- Files:
  - Standard Test:
    - `xmltest`
  - Injected Memory Leak Test:
    - `xmltest_memleak`

### GCC/Clang Test Outputs
**Test Outputs:**
- Folders:
  - Standard Test:
    - `/work/bazel-testlogs/xmltest`
  - Injected Memory Leak Test:
    - `/work/bazel-testlogs/xmltest_memleak`
- Files:
  - `test.log`
  - `test.xml`

### Mingw Build Outputs
**Library Project:**
- Folders: 
  - `/work/bazel-bin/libtinyxml2_shared.dll.runfiles/__main__/`
- Files:
  - `tinyxml2.h`
  - `tinyxml2_shared.dll`

**Executable Project:**
- Folders:
  - Standard Test:
    - `/work/bazel-bin/xmltest.exe.runfiles/__main__/`
    - `/work/bazel-bin/xmltest.exe.runfiles/__main__/resources/`  (resources needed for testing)
  - Injected Memory Leak Test:
    - `/work/bazel-bin/xmltest_memleak.exe.runfiles/__main__/`
    - `/work/bazel-bin/xmltest_memleak.exe.runfiles/__main__/resources/`  (resources needed for testing)
- Files:
  - Standard Test:
    - `xmltest.exe`
  - Injected Memory Leak Test:
    - `xmltest_memleak.exe`

## CI Pipeline Configuration Details (Github Actions)
For this project, I created a Github Actions CI pipeline `.github\workflows\docker_container_workflow.yml` for the primary Linux configurations implemented. This includes both using gcc and clang as well as with and without tsan and asan. These configurations are run using the matrix strategy such that every time the pipeline is executed, every variation of the build is compiled, and the tests are run for complete coverage. I looked at it from the perspective that in a real build system, if you were compiling for multiple platforms, something similar would be expected to be done. 

Currently, the CI Pipeline is setup to only run the test suite provided with tinyxml2 and does not create an artifact for the binaries. The reason for this is because github counts that against my monthly allocated space for a free account and I wanted to make sure I avoided going over Github's free allocated budget. I do however package the test log outputs to show the ability to create an artifact in the build system.

Additionally, I created a slightly modified version of my Dockerfile called `Dockerfile_GithubActions` for running on GitHub. Essentially, I updated the Dockerfile to not automatically exit so that the CI pipeline could call different commands on different steps for better output granularity. 

Lastly, as mentioned in my emails, I did run into an issue with tinyxml2's test executable causing a segmentation fault while executing on Github's servers. I thoroughly tested locally using both my local Linux Mint virtual machine and well as in docker container I have provided running on my virtual machine. I could not reproduce this issue locally. I tried debugging this for several hours using an array of configurations with and without docker and continued to run into the same problem on GitHub's runner. From your team's feedback, it does seem that you have also seen similar behavior before with this library and it seems to be an internal problem with the library itself. The stack trace also seems to point to something similar as well.
