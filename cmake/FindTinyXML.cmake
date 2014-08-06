

if(DEFINED __STANDARD_FIND_MODULE_INCLUDED)
  return()
endif()
set(__STANDARD_FIND_MODULE_INCLUDED TRUE)


include(FindPackageHandleStandardArgs)
include(CMakeParseArguments)
include(SelectLibraryConfigurations)
include(ExtractVersion)

macro(STANDARD_FIND_MODULE _name _pkgconfig_name)
    string(TOUPPER ${_name} _NAME)
    cmake_parse_arguments(_OPT_${_NAME} "NOT_REQUIRED;SKIP_CMAKE_CONFIG;SKIP_PKG_CONFIG" "" "" "${ARGN}")

    # Try to use CMake Config file to locate the package
    if(NOT _OPT_${_NAME}_SKIP_CMAKE_CONFIG)
        set(_${_name}_FIND_QUIETLY ${${_name}_FIND_QUIETLY})
        find_package(${_name} QUIET NO_MODULE)
        set(${_name}_FIND_QUIETLY ${_${_name}_FIND_QUIETLY})
        mark_as_advanced(${_name}_DIR)

        if(${_name}_FOUND)
            find_package_handle_standard_args(${_name} CONFIG_MODE)
        endif()
    endif()

    if(NOT ${_name}_FOUND AND NOT _OPT_${_NAME}_SKIP_PKG_CONFIG)
        # No CMake Config file was found. Try using PkgConfig
        find_package(PkgConfig QUIET)
        if(PKG_CONFIG_FOUND)

            if(${_name}_FIND_VERSION)
                if(${_name}_FIND_VERSION_EXACT)
                    pkg_check_modules(_PC_${_NAME} QUIET ${_pkgconfig_name}=${${_name}_FIND_VERSION})
                else(${_name}_FIND_VERSION_EXACT)
                    pkg_check_modules(_PC_${_NAME} QUIET ${_pkgconfig_name}>=${${_name}_FIND_VERSION})
                endif(${_name}_FIND_VERSION_EXACT)
            else(${_name}_FIND_VERSION)
                pkg_check_modules(_PC_${_NAME} QUIET ${_pkgconfig_name})
            endif(${_name}_FIND_VERSION)


            if(_PC_${_NAME}_FOUND)
                set(${_name}_INCLUDE_DIRS ${_PC_${_NAME}_INCLUDE_DIRS} CACHE PATH "${_name} include directory")
                set(${_name}_DEFINITIONS ${_PC_${_NAME}_CFLAGS_OTHER} CACHE STRING "Additional compiler flags for ${_name}")

                set(${_name}_LIBRARIES)
                foreach(_library IN ITEMS ${_PC_${_NAME}_LIBRARIES})
                    string(TOUPPER ${_library} _LIBRARY)
                    find_library(${_name}_${_LIBRARY}_LIBRARY_RELEASE
                                 NAMES ${_library}
                                 PATHS ${_PC_${_NAME}_LIBRARY_DIRS})
                    list(APPEND ${_name}_LIBRARIES ${${_name}_${_LIBRARY}_LIBRARY_RELEASE})
                    select_library_configurations(${_name}_${_LIBRARY})
                    if(STANDARD_FIND_MODULE_DEBUG OR STANDARD_FIND_MODULE_DEBUG_${_name})
                        message(STATUS "${_name}_${_LIBRARY}_FOUND = ${${_name}_${_LIBRARY}_FOUND}")
                        message(STATUS "${_name}_${_LIBRARY}_LIBRARY_RELEASE = ${${_name}_${_LIBRARY}_LIBRARY_RELEASE}")
                        message(STATUS "${_name}_${_LIBRARY}_LIBRARY_DEBUG = ${${_name}_${_LIBRARY}_LIBRARY_DEBUG}")
                        message(STATUS "${_name}_${_LIBRARY}_LIBRARY = ${${_name}_${_LIBRARY}_LIBRARY}")
                    endif()
                endforeach()

                set(${_name}_VERSION ${_PC_${_NAME}_VERSION})

            endif(_PC_${_NAME}_FOUND)

            mark_as_advanced(${_name}_INCLUDE_DIRS
                             ${_name}_DEFINITIONS)

            # If NOT_REQUIRED unset the _FIND_REQUIRED variable and save it for later
            if(_OPT_${_NAME}_NOT_REQUIRED AND DEFINED ${_name}_FIND_REQUIRED)
                set(_${_name}_FIND_REQUIRED ${${_name}_FIND_REQUIRED})
                set(_${_name}_FIND_QUIETLY ${${_name}_FIND_QUIETLY})
                unset(${_name}_FIND_REQUIRED)
                set(${_name}_FIND_QUIETLY 1)
            endif()

            find_package_handle_standard_args(${_name} DEFAULT_MSG ${_name}_LIBRARIES)

            # If NOT_REQUIRED reset the _FIND_REQUIRED variable
            if(_OPT_${_NAME}_NOT_REQUIRED AND DEFINED _${_name}_FIND_REQUIRED)
                set(${_name}_FIND_REQUIRED ${_${_name}_FIND_REQUIRED})
                set(${_name}_FIND_QUIETLY ${_${_name}_FIND_QUIETLY})
            endif()

        endif()
    endif()

    # ${_name}_FOUND is uppercase after find_package_handle_standard_args
    set(${_name}_FOUND ${${_NAME}_FOUND})

    # Extract version numbers
    if(${_name}_FOUND)
        extract_version(${_name})
    endif()


    # Print some debug output if either STANDARD_FIND_MODULE_DEBUG
    # or STANDARD_FIND_MODULE_DEBUG_${_name} is set to TRUE
    if(STANDARD_FIND_MODULE_DEBUG OR STANDARD_FIND_MODULE_DEBUG_${_name})
        message(STATUS "${_name}_FOUND = ${${_name}_FOUND}")
        message(STATUS "${_name}_INCLUDE_DIRS = ${${_name}_INCLUDE_DIRS}")
        message(STATUS "${_name}_LIBRARIES = ${${_name}_LIBRARIES}")
        message(STATUS "${_name}_DEFINITIONS = ${${_name}_DEFINITIONS}")
        message(STATUS "${_name}_VERSION = ${${_name}_VERSION}")
        message(STATUS "${_name}_MAJOR_VERSION = ${${_name}_MAJOR_VERSION}")
        message(STATUS "${_name}_MINOR_VERSION = ${${_name}_MINOR_VERSION}")
        message(STATUS "${_name}_PATCH_VERSION = ${${_name}_PATCH_VERSION}")
        message(STATUS "${_name}_TWEAK_VERSION = ${${_name}_TWEAK_VERSION}")
    endif()

endmacro()


standard_find_module(TinyXML tinyxml)

# Set package properties if FeatureSummary was included
if(COMMAND set_package_properties)
    set_package_properties(TinyXML PROPERTIES DESCRIPTION "A small, simple XML parser for the C++ language"
                                              URL "http://www.grinninglizard.com/tinyxml/index.html")
endif()
