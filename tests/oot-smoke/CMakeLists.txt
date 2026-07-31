cmake_minimum_required(VERSION 3.27)

project(gr4_oot_smoke LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(gnuradio4 CONFIG REQUIRED)
find_package(gnuradio4Library CONFIG REQUIRED)
find_package(gnuradio4Blocks CONFIG REQUIRED)

add_executable(gr4_oot_smoke main.cpp)
target_link_libraries(
  gr4_oot_smoke
  PRIVATE
    gnuradio4::gnuradio-core
    gnuradio4::gnuradio-algorithm
    gnuradio4::gr-math)

enable_testing()
add_test(NAME installed_sdk_consumer COMMAND gr4_oot_smoke)
