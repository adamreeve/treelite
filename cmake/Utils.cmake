# Automatically set source group based on folder
function(auto_source_group SOURCES)

  foreach(FILE ${SOURCES})
      get_filename_component(PARENT_DIR "${FILE}" PATH)

      # skip src or include and changes /'s to \\'s
      string(REPLACE "${CMAKE_CURRENT_LIST_DIR}" "" GROUP "${PARENT_DIR}")
      string(REPLACE "/" "\\\\" GROUP "${GROUP}")
      string(REGEX REPLACE "^\\\\" "" GROUP "${GROUP}")

      source_group("${GROUP}" FILES "${FILE}")
  endforeach()
endfunction(auto_source_group)

# Set output directory of target, ignoring debug or release
function(set_output_directory target dir)
  set_target_properties(${target} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${dir}              # for executable
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${dir}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${dir}
    LIBRARY_OUTPUT_DIRECTORY ${dir}              # for shared library
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ${dir}
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${dir}
    ARCHIVE_OUTPUT_DIRECTORY ${dir}              # for static library
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${dir}
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${dir}
  )
endfunction(set_output_directory)

# Set a default build type to release if none was specified
function(set_default_configuration_release)
  if(CMAKE_CONFIGURATION_TYPES STREQUAL "Debug;Release;MinSizeRel;RelWithDebInfo") # multiconfig generator?
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)
  elseif(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE )
  endif()
endfunction(set_default_configuration_release)
