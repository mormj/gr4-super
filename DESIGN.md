# Design notes

## What `gr4-dev-super` does today

The existing workspace combines several responsibilities:

1. `repos.yaml` plus `bootstrap.sh` clone and pin working copies.
2. `build-all.sh` configures, builds, and installs each repository in manifest
   order.
3. Every repository has an independent build directory.
4. One install prefix is added to `CMAKE_PREFIX_PATH` so downstream
   repositories find upstream packages.
5. Argument files provide global and per-repository configuration.
6. `dev-env.sh` provides the runtime library, package, executable, and plugin
   search paths.
7. Additional scripts provide diagnostics, cleanup, scaffolding, memory
   profiling, containers, and services.

Items 2 through 5 are the actual build graph. The remaining items are useful
workspace tooling, but do not need to be reproduced to prove a CMake-based
solution.

## Recommended model

Use a CMake superbuild based on `ExternalProject`, not a unified
`add_subdirectory()` build.

```text
gnuradio4-core
      |
      v
gnuradio4-library
      |
      v
gnuradio4-blocks
      ├── out-of-tree projects
      ├── gr4-incubator
      ├── gnuradio4-control-plane
      └── gnuradio4-studio blocks
                    |
                    v
          gnuradio4-studio application

All install into: <super-repo>/install
```

This retains the package boundaries developers and CI encounter when each
repository is built alone. It also lets each repository retain its own cache,
options, generated files, and test tree.

## Deliberate simplifications

- The primary and optional upstream repositories are declared directly in
  `CMakeLists.txt`; a separate YAML parser is unnecessary for this small graph.
- CMake clones only missing first-party sources. A guarded download script
  refuses to replace a non-empty directory and never updates an existing
  working copy, so normal branch-based development remains safe.
- A preset replaces shared argument files for the common configuration.
- Global and per-component cache variables plus `projects.local.cmake` replace
  per-repository argument files.
- Package and feature selection remains owned by each component. The superbuild
  forwards component-specific CMake arguments without mirroring every child
  option as a top-level option.
- A generated activation script contains only paths needed after installation.
- CMake source subdirectories and a small Node-project adapter cover Studio
  without turning the entire workspace into one CMake target namespace.
- The Node adapter hashes `package.json` and `package-lock.json`, running
  `npm ci` only when those inputs or `node_modules` change.
- Command-line OOT projects build by default; their CTest trees are registered
  only when the explicit `TESTS` keyword is used.
- Scaffolding, profiling, Docker, and service management stay outside the
  build graph and can be added independently if they prove necessary.

## Tradeoffs

`ExternalProject` does not model individual source files in the outer build.
`BUILD_ALWAYS` therefore asks each inner CMake build to run on every outer
build. With Ninja this is still incremental: unchanged repositories quickly
report that there is no work.

The shared prefix is intentionally mutable. Removing or renaming installed
files can leave stale artifacts there. During normal development, remove the
`install/` directory when an install-layout change makes the prefix suspect.

Tests remain owned by each child project. The superbuild's `check` target runs
registered CTest trees, Studio's Node tests, and an installed-SDK smoke test:

```sh
cmake --build --preset full --target check
```
