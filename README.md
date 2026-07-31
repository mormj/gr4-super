<p align="center">
  <img
    src="https://raw.githubusercontent.com/gnuradio/gnuradio4-core/main/docs/logo.png"
    alt="GNU Radio 4"
    width="30%">
</p>

# GNU Radio 4.0

> [!IMPORTANT]
> GNU Radio 4.0 (GR4) is currently in a maturing beta state as it approaches
> its first stable release. It is suitable for evaluation, experimentation,
> and early development. GNU Radio 3.x remains the stable release series for
> users who require the existing production-supported platform.

GNU Radio is a free and open-source signal-processing runtime and software
development toolkit. It began in software-defined radio and wireless
communications, and is also used in research, education, radio astronomy,
particle physics, test systems, and commercial applications.

This is the top-level GNU Radio 4 development workspace. It brings together the
three primary GNU Radio 4 repositories and provides one CMake entry point for
building the complete project:

| Repository | Contents |
| --- | --- |
| `gnuradio4-core` | Runtime, scheduler, graph and block model, plugin infrastructure, and block-development SDK |
| `gnuradio4-library` | Reusable DSP algorithms and supporting libraries |
| `gnuradio4-blocks` | Standard GNU Radio 4 signal-processing blocks |
| `gr4-incubator` | Optional staging area for experimental blocks, schedulers, and utilities |
| `gnuradio4-control-plane` | Optional runtime and HTTP control service |
| `gnuradio4-studio` | Optional Studio blocks and browser/desktop application |

Each component remains an independent repository and CMake project:

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
```

The top-level build configures each repository separately, builds them in
dependency order, and installs them into a shared development prefix. This
preserves the same package boundaries used by standalone and out-of-tree
projects.

## What's New in GNU Radio 4.0?

GNU Radio 4.0 is a major modernization of the GNU Radio runtime, block model,
and application architecture. It retains the familiar workflow of constructing
signal-processing systems from reusable blocks and flowgraphs while introducing
a modern C++ foundation and more flexible runtime behavior.

- **Familiar flowgraph model:** Blocks and flowgraphs remain central to GNU
  Radio applications.
- **Modern C++ block development:** C++23 APIs and compile-time reflection make
  blocks direct, type-safe, and maintainable.
- **Stronger data types:** Flowgraphs can use fundamental numeric types,
  complex samples, structured values, and application-specific types.
- **High-performance runtime:** Lock-free buffers, compile-time optimization,
  and SIMD support provide efficient signal processing.
- **Flexible scheduling:** Schedulers can be selected or developed for
  throughput, latency, parallelism, and application-specific requirements.
- **Recursive flowgraphs and feedback:** Graphs can express feedback loops and
  more complex execution structures.
- **Extensible block ecosystem:** Installed CMake packages, block-registration
  tooling, and runtime plugins support independently developed block libraries.
- **Broader execution targets:** The architecture supports native CPUs,
  WebAssembly, and future heterogeneous execution environments.

## Requirements

GNU Radio 4 uses C++23. The primary projects currently require:

- CMake 3.27 or newer
- Ninja
- GCC 14 or newer; GCC 15 or newer is recommended
- Clang 20 or newer is recommended when using Clang
- Git for obtaining the component repositories
- Node.js 22 and npm when building the complete Studio workspace

Individual block modules and optional features may require additional system
packages. By default, the development presets allow the component projects to
fetch selected dependencies.

## Build GNU Radio 4

Configure and build the normal development profile:

```sh
cmake --preset dev
cmake --build --preset dev
source build/dev/activate.sh
```

On the first build, CMake clones missing component repositories into `src/`.
Existing working copies are developer-owned: the superbuild does not fetch,
switch branches, or otherwise modify them.

The default build performs three independent configure/build/install cycles in
dependency order. All three components are available through the aggregate
`gr4` target, which is also the default target.

### Build profiles

| Preset | Configuration | Intended use | Install prefix |
| --- | --- | --- | --- |
| `dev` | RelWithAssert, tests, warnings as errors | Normal development | `install/` |
| `debug` | Debug, tests | Debugger-friendly development | `install/debug/` |
| `release` | Release, no tests | Performance and installation validation | `install/release/` |
| `asan` | Debug, tests, AddressSanitizer | Memory-error diagnostics | `install/asan/` |
| `ubsan` | Debug, tests, UndefinedBehaviorSanitizer | Undefined-behavior diagnostics | `install/ubsan/` |
| `offline` | RelWithAssert, tests, system dependencies | Build without dependency downloads | `install/offline/` |
| `ci` | RelWithAssert, tests, warnings as errors | Reproducible CI builds | `install/ci/` |
| `full` | RelWithAssert, tests, incubator, control-plane, Studio | Complete application development | `install/full/` |
| `full-ci` | RelWithAssert, tests, incubator, control-plane, Studio | Complete integration CI | `install/full-ci/` |

Use the same preset name to configure, build, and activate a profile:

```sh
cmake --preset debug
cmake --build --preset debug
source build/debug/activate.sh
```

List the available presets with:

```sh
cmake --list-presets
cmake --build --list-presets
```

### Custom user profiles

Keep machine-local profiles in `CMakeUserPresets.json`. CMake loads this file
alongside the checked-in presets, and the superrepo ignores it so paths and
personal build choices are not committed accidentally. For example:

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "my-radio",
      "inherits": "dev",
      "binaryDir": "${sourceDir}/build/my-radio",
      "cacheVariables": {
        "CMAKE_INSTALL_PREFIX": "${sourceDir}/install/my-radio",
        "GR4_BLOCKS_CMAKE_ARGS": "-DENABLE_EXAMPLES=OFF"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "my-radio",
      "configurePreset": "my-radio",
      "jobs": 0
    }
  ]
}
```

The named profile then behaves like a supplied profile:

```sh
cmake --preset my-radio
cmake --build --preset my-radio
source build/my-radio/activate.sh
```

Curated top-level options cover cross-workspace choices. The component-specific
`GR4_*_CMAKE_ARGS` variables pass advanced options only to their owning child
project. These variables can use only options already exposed by that
repository. For example, the current blocks project provides opt-in audio and
SDR options, but its standard block modules are built unconditionally.

### Build individual components

Targets include their upstream dependencies. For example, building
`gnuradio4-blocks` first ensures that core and library are installed.

```sh
cmake --build --preset dev --target gnuradio4-core
cmake --build --preset dev --target gnuradio4-library
cmake --build --preset dev --target gnuradio4-blocks
```

### Build incubator, control-plane, and Studio

The `full` preset adds gr4-incubator, control-plane, Studio's CMake block
plugins, and the Node/Vite desktop application:

```sh
cmake --preset full
cmake --build --preset full
source build/full/activate.sh
gr4-studio
```

The build installs the following into `install/full/`:

```text
bin/gr4cp_server
bin/gr4cp-cli
bin/gr4-studio
lib/                         # GNU Radio and Studio plugins
share/gr4-studio/            # frontend and desktop assets
```

Application targets can also be built individually:

```sh
cmake --build --preset full --target gnuradio4-control-plane
cmake --build --preset full --target gr4-incubator
cmake --build --preset full --target gnuradio4-studio-blocks
cmake --build --preset full --target gnuradio4-studio
```

`gnuradio4-studio` installs its locked npm dependencies, builds the desktop
bundle, and installs it into the profile prefix. The dependency installation is
repeated automatically when `package.json` or `package-lock.json` changes. Its
build depends on both the Studio blocks and control-plane in the `full` preset.

Incubator, control-plane, and Studio can be enabled independently without using
the preset:

```sh
cmake --preset dev -DGR4_ENABLE_INCUBATOR=ON
cmake --preset dev -DGR4_ENABLE_CONTROL_PLANE=ON
cmake --preset dev -DGR4_ENABLE_STUDIO=ON
```

Studio without control-plane supports remote-backend use; enable both for the
normal local desktop experience.

Clone the normal profile's missing sources without compiling:

```sh
cmake --build --preset dev --target sources
```

Use `--preset full` to clone the incubator, control-plane, and Studio sources
as well.

Build the complete stack and run all component and installed-SDK tests:

```sh
cmake --build --preset dev --target check
```

Remove one component's build state without touching its source or the shared
installation:

```sh
cmake --build --preset dev --target gnuradio4-blocks-clean
```

Edits under `src/` are picked up by the next build. The outer build invokes each
required child build, while the child Ninja builds perform only incremental
work.

## Testing

Tests belong to their component repositories and run from the corresponding
child build directory:

```sh
ctest --test-dir build/dev/projects/gnuradio4-core --output-on-failure
ctest --test-dir build/dev/projects/gnuradio4-library --output-on-failure
ctest --test-dir build/dev/projects/gnuradio4-blocks --output-on-failure
```

With the `full` preset, `check` additionally runs incubator and control-plane
CTest, Studio block CTest, and Studio's lint and Vitest commands. The `release`
preset disables test builds. All other supplied presets enable them.

The `check` target also builds and runs `tests/oot-smoke`, a small external
consumer that discovers all three installed CMake packages. This verifies the
public SDK rather than accidentally using headers or targets from the source
trees.

## Developing GNU Radio 4

The repositories under `src/` are normal Git working copies. Sources cloned by
the superbuild begin on a detached commit corresponding to the requested ref;
create a branch before committing:

```sh
cd src/gnuradio4-blocks
git switch -c my-feature
```

Commit, push, and use each repository's own development documentation and issue
tracker as usual. Reconfiguring the top-level workspace does not fetch, update,
switch, or reset those working copies.

To use component checkouts stored somewhere else:

```sh
cmake --preset dev -DGR4_SOURCE_ROOT=/path/to/sources
cmake --build --preset dev
```

The source root must contain:

```text
gnuradio4-core/
gnuradio4-library/
gnuradio4-blocks/
gnuradio4-control-plane/     # when enabled
gnuradio4-studio/            # when enabled
```

The generated `activate.sh` adds the selected install prefix to the executable,
CMake package, pkg-config, configured runtime-library, discovered Python
site-package, and GNU Radio plugin search paths.

## Out-of-Tree Projects

An out-of-tree CMake project can participate in the same build and consume the
installed GNU Radio 4 packages:

```sh
cmake --preset dev -DGR4_EXTRA_PROJECTS=/path/to/gr4-example
cmake --build --preset dev --target gr4-example
```

Extra projects registered this way depend on the complete first-party stack.
They are built by the aggregate target but are not assumed to provide CTest
tests.

For multiple projects or custom dependency relationships, copy
`projects.local.cmake.example` to the ignored `projects.local.cmake` file and
declare each project explicitly:

```cmake
gr4_add_project(
  my-gr4-module
  SOURCE_DIR "../my-gr4-module"
  DEPENDS gnuradio4-blocks
  CMAKE_ARGS
    "-DENABLE_PLUGINS:BOOL=ON"
  TESTS)
```

`TESTS` registers the project's child CTest tree with the top-level `check`
target and requires that tree to contain at least one test. Use the explicit
form for an OOT project whose tests should participate in `check`.
Project-specific configuration belongs in its `CMAKE_ARGS` list. Options that
should apply to every component may be supplied through `GR4_EXTRA_CMAKE_ARGS`:

```sh
cmake --preset dev \
  -DGR4_EXTRA_CMAKE_ARGS="-DUSE_CCACHE=ON;-DGR_BUILD_PARALLEL_LEVEL=6"
```

## Top-Level CMake Options

| Option | Default | Description |
| --- | ---: | --- |
| `GR4_SOURCE_ROOT` | `src/` | Location of the first-party source repositories |
| `GR4_EXTRA_PROJECTS` | empty | Additional CMake project paths |
| `GR4_EXTRA_CMAKE_ARGS` | empty | Additional CMake arguments for every child project |
| `GR4_CORE_CMAKE_ARGS` | empty | Additional arguments for core only |
| `GR4_LIBRARY_CMAKE_ARGS` | empty | Additional arguments for library only |
| `GR4_BLOCKS_CMAKE_ARGS` | empty | Additional arguments for blocks only |
| `GR4_INCUBATOR_CMAKE_ARGS` | empty | Additional arguments for incubator only |
| `GR4_CONTROL_PLANE_CMAKE_ARGS` | empty | Additional arguments for control-plane only |
| `GR4_STUDIO_BLOCKS_CMAKE_ARGS` | empty | Additional arguments for Studio blocks only |
| `GR4_CORE_REPOSITORY` | GNU Radio GitHub repository | Core clone source |
| `GR4_CORE_REF` | `main` | Core branch, tag, or commit |
| `GR4_LIBRARY_REPOSITORY` | GNU Radio GitHub repository | Library clone source |
| `GR4_LIBRARY_REF` | `main` | Library branch, tag, or commit |
| `GR4_BLOCKS_REPOSITORY` | GNU Radio GitHub repository | Blocks clone source |
| `GR4_BLOCKS_REF` | `main` | Blocks branch, tag, or commit |
| `GR4_INCUBATOR_REPOSITORY` | GNU Radio GitHub repository | Incubator clone source |
| `GR4_INCUBATOR_REF` | `main` | Incubator branch, tag, or commit |
| `GR4_CONTROL_PLANE_REPOSITORY` | GNU Radio GitHub repository | Control-plane clone source |
| `GR4_CONTROL_PLANE_REF` | `main` | Control-plane branch, tag, or commit |
| `GR4_STUDIO_REPOSITORY` | GNU Radio GitHub repository | Studio clone source |
| `GR4_STUDIO_REF` | `main` | Studio branch, tag, or commit |
| `GR4_ENABLE_INCUBATOR` | `OFF` | Build and install incubator |
| `GR4_ENABLE_CONTROL_PLANE` | `OFF` | Build and install control-plane |
| `GR4_ENABLE_STUDIO` | `OFF` | Build and install Studio blocks and application |
| `GR4_BUILD_TESTING` | `ON` | Build tests in child projects |
| `GR4_FETCH_DEPS` | `ON` | Allow child projects to fetch selected dependencies |
| `GR4_WARNINGS_AS_ERRORS` | `ON` | Treat child-project warnings as errors |
| `GR4_ADDRESS_SANITIZER` | `OFF` | Enable AddressSanitizer in child projects |
| `GR4_UB_SANITIZER` | `OFF` | Enable UndefinedBehaviorSanitizer in child projects |
| `BUILD_SHARED_LIBS` | `ON` | Build shared libraries |
| `CMAKE_INSTALL_PREFIX` | `install/` | Shared installation prefix |
| `CMAKE_INSTALL_LIBDIR` | `lib` | Library directory, relative to the shared prefix |

## Why Separate Child Builds?

`gnuradio4-library` consumes the installed `gnuradio4` package.
`gnuradio4-blocks` consumes both the installed core and library packages.
Out-of-tree modules use those same installed CMake packages and tools.

A single `add_subdirectory()` tree would combine the projects' cache variables,
dependency targets, generated files, and target namespaces. Separate child
builds keep those boundaries explicit and ensure the workspace represents how
GNU Radio 4 is packaged and consumed outside this repository.

## Continuous Integration

The top-level GitHub Actions workflow performs one complete integration build
using the GNU Radio Ubuntu 24.04 GCC 14 CI image:

```sh
cmake --preset full-ci
cmake --build --preset full-ci --target check
```

The component repositories retain responsibility for their larger compiler,
platform, sanitizer, coverage, and WebAssembly matrices. This repository checks
the contract between the components: ordered installation, package discovery,
component tests, incubator, control-plane, Studio blocks, the Studio frontend,
and consumption by an out-of-tree project.

In addition to pushes and pull requests, a daily scheduled run builds the
latest default revisions to detect compatibility drift between repositories.
Manual workflow runs accept repository and revision overrides for all six
components. This supports coordinated changes across repositories and testing
branches from forks without changing the checked-in defaults.

## Helpful Links

- [GNU Radio website](https://gnuradio.org/)
- [GNU Radio wiki](https://wiki.gnuradio.org/)
- [GNU Radio 4 core issue tracker](https://github.com/gnuradio/gnuradio4-core/issues)
- [GNU Radio mailing-list archive](https://lists.gnu.org/archive/html/discuss-gnuradio/)
- [Subscribe to the GNU Radio mailing list](https://lists.gnu.org/mailman/listinfo/discuss-gnuradio)
- [GNU Radio Matrix chat](https://chat.gnuradio.org/)
- [GNU Radio 4 technical discussion](https://matrix.to/#/#gr4-technical-users:gnuradio.org)

## License and Copyright

The superrepo's CMake orchestration, CI configuration, helper scripts, and
documentation are distributed under the [MIT License](LICENSE).

GNU Radio 4 core and runtime code is distributed under the MIT License, keeping
it free for personal, academic, and commercial use. Individual block libraries
may use other compatible licenses, including GPLv3. Consult each component
repository for its authoritative license and contribution terms.

Copyright (C) The GNU Radio Authors  
Copyright (C) Contributors to the GNU Radio Project  
Copyright (C) FAIR - Facility for Antiproton & Ion Research, Darmstadt, Germany

GNU Radio acknowledges GSI/FAIR and the wider GNU Radio community for their
contributions to the design and development of GNU Radio 4.0.
