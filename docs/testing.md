# Testing

Tests remain owned by their component repositories. Run an individual child
test tree after building its profile:

```sh
ctest --test-dir build/dev/projects/gnuradio4-core --output-on-failure
ctest --test-dir build/dev/projects/gnuradio4-library --output-on-failure
ctest --test-dir build/dev/projects/gnuradio4-blocks --output-on-failure
```

Run the selected workspace's complete integration check with:

```sh
cmake --build --preset dev --target check
```

For the full profile, `check` also runs incubator and control-plane CTest,
Studio-block CTest, and Studio's lint and Vitest commands. The `release`
profile disables test builds; all other supplied profiles enable them.

`check` additionally builds and runs `tests/oot-smoke`, an external consumer
that discovers all three installed CMake packages. It verifies the installed
SDK rather than allowing headers or CMake targets from source trees to leak
into consumer builds.
