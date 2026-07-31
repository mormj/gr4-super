foreach(required_variable GIT_EXECUTABLE SOURCE_DIR SOURCE_MARKER GIT_REPOSITORY GIT_TAG)
  if(NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message(FATAL_ERROR "${required_variable} is required")
  endif()
endforeach()

if(EXISTS "${SOURCE_DIR}/${SOURCE_MARKER}")
  message(STATUS "Using existing source: ${SOURCE_DIR}")
  return()
endif()

if(EXISTS "${SOURCE_DIR}/.git")
  message(FATAL_ERROR
    "Existing Git checkout is missing expected source marker "
    "'${SOURCE_MARKER}': ${SOURCE_DIR}")
endif()

if(EXISTS "${SOURCE_DIR}")
  file(GLOB contents LIST_DIRECTORIES TRUE "${SOURCE_DIR}/*")
  if(contents)
    message(FATAL_ERROR
      "Refusing to replace non-empty source directory without '${SOURCE_MARKER}': ${SOURCE_DIR}")
  endif()
endif()

cmake_path(GET SOURCE_DIR PARENT_PATH source_parent)
file(MAKE_DIRECTORY "${source_parent}")

set(staging_dir "${SOURCE_DIR}.gr4-super-clone")
if(EXISTS "${staging_dir}")
  message(FATAL_ERROR
    "A previous clone staging directory exists; remove it before retrying: ${staging_dir}")
endif()

function(run_git)
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" ${ARGN}
    RESULT_VARIABLE result
    ERROR_VARIABLE error)
  if(NOT result EQUAL 0)
    if(DEFINED staging_dir AND EXISTS "${staging_dir}")
      file(REMOVE_RECURSE "${staging_dir}")
    endif()
    message(FATAL_ERROR "Git command failed (${result}): ${error}")
  endif()
endfunction()

message(STATUS "Cloning ${GIT_REPOSITORY} (${GIT_TAG}) into ${SOURCE_DIR}")
file(MAKE_DIRECTORY "${staging_dir}")
run_git(-C "${staging_dir}" init --quiet)
run_git(-C "${staging_dir}" remote add origin "${GIT_REPOSITORY}")
run_git(-C "${staging_dir}" fetch --quiet --depth 1 origin "${GIT_TAG}")
run_git(-C "${staging_dir}" checkout --quiet --detach FETCH_HEAD)

# ExternalProject may have created the empty destination while preparing its
# directory layout. It was checked for content above and is safe to replace.
file(REMOVE_RECURSE "${SOURCE_DIR}")
file(RENAME "${staging_dir}" "${SOURCE_DIR}")
