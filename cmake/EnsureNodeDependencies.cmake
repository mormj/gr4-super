foreach(required_variable NPM_EXECUTABLE SOURCE_DIR STAMP_DIR)
  if(NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message(FATAL_ERROR "${required_variable} is required")
  endif()
endforeach()

set(package_file "${SOURCE_DIR}/package.json")
set(lock_file "${SOURCE_DIR}/package-lock.json")
foreach(required_file package_file lock_file)
  if(NOT EXISTS "${${required_file}}")
    message(FATAL_ERROR "Missing Node dependency file: ${${required_file}}")
  endif()
endforeach()

file(SHA256 "${package_file}" package_hash)
file(SHA256 "${lock_file}" lock_hash)
set(dependency_hash "${package_hash}-${lock_hash}")
set(hash_file "${STAMP_DIR}/node-dependencies.sha256")

set(installed_hash "")
if(EXISTS "${hash_file}")
  file(READ "${hash_file}" installed_hash)
  string(STRIP "${installed_hash}" installed_hash)
endif()

if(installed_hash STREQUAL dependency_hash AND EXISTS "${SOURCE_DIR}/node_modules")
  message(STATUS "Node dependencies are current")
  return()
endif()

message(STATUS "Installing Node dependencies from package-lock.json")
execute_process(
  COMMAND "${NPM_EXECUTABLE}" --prefix "${SOURCE_DIR}" ci
  WORKING_DIRECTORY "${SOURCE_DIR}"
  RESULT_VARIABLE npm_result
  COMMAND_ECHO STDOUT)
if(NOT npm_result EQUAL 0)
  message(FATAL_ERROR "npm ci failed with exit code ${npm_result}")
endif()

file(MAKE_DIRECTORY "${STAMP_DIR}")
file(WRITE "${hash_file}" "${dependency_hash}\n")
