# Pale Moon nix-shell enviroment.

Generate environments for building Pale Moon in isolation from the system. 

This repository contain a simple file which can be used to build Pale Moon out of the sources, or to make a build environment that can be used for buildin Pale Moon.

To generate the build environments you will have to install [Nix](https://nixos.org/nix), or run the NixOS Linux distro. Even if Nix can be installed in user-space, it is recommended to install Nix as a system administrator, to benefit from the pre-compiled binaries.

## Generating build environments

A build environment can easily be generate for you for different architectures, such as `i686-linux` and `x86_64-linux`. These are used to specify the platform used for the tool chain. Using `i686-linux` will build a 32-bits toolchain, while using `x86_64-linx` will build a 64-bits toolchain.

Then, for each architecture, you can choose different compilers, such as `gcc49`, `gcc48`, `gcc472` — which is used for linux slaves on treeherder — or `clang35`.  (See the content of `release.nix` file for a complete list of supported compilers.)

These are specified on the command line of the `nix-shell` tool which is installed with the latest versions of Nix.

The `nix-shell` tool is used to evaluate the expression and build the toolchain that you requested. The first time you use this command, it will pull binaries and build the dependencies which are not available on a remote server.  The second time, it will reuse the tool chain that it produced before.

The following `nix-shell` command will build a 64-bits toolchain with gcc 4.9.2.  The `--pure` argument is optional, and it reset your environment to avoid having environment pollution while building.  In addition, you can use the `--command <cmd>` to execute shell commands directly within this environment.

```
λ nix-shell ./firefox-build-env/release.nix -A build.x86_64-linux.gcc --pure
<... new shell should be intialized.>
nix-shell$ cd ./Pale-Moon
nix-shell$ ./mach build
nix-shell$ ./mach run
nix-shell$ exit
```

## Building Pale Moon

In addition to the above, you can use the `nix-build` tool to build the source of Pale Moon with the specified tool chain.  Warning, that this command will make a copy of the source before doing the compilation. (Currently untested, so unsupported.)

You will have to specify on the command line the path to use to find the source with the `--arg gecko <path>` argument. The `-o <result>` is used to write a symlink on `<result>` which contains the installation directory of Firefox.

```
$ nix-build ./firefox-build-env/release.nix -A build.x86_64-linux.gcc --arg gecko ./mozilla-inbound -o firefox-x64-gcc
```

Most of this repository was ripped from: https://github.com/nbp/firefox-build-env
(So this shell can likely build Firefox as well.)

