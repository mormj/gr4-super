# Some external projects add tests without enabling CTest at their top level.
# Loading this through CMAKE_PROJECT_INCLUDE keeps that compatibility shim in
# the superbuild rather than modifying a developer-owned source checkout.
include(CTest)
enable_testing()
