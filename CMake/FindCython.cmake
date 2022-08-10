# code adapted from 
# https://github.com/symengine/symengine.py/blob/master/cmake/FindCython.cmake
# MIT License https://github.com/symengine/symengine.py/blob/master/LICENSE
# 16/11/18
#
# Cython
#

# This finds the "cython" executable in your PATH, and then in some standard
# paths:
SET(CYTHON_EXECUTABLE cython CACHE STRING "Cython executable name")
SET(CYTHON_FLAGS --cplus --fast-fail)

set(SEARCH_CYTHON_PATH "")
if (CYTHON_ROOT)
  set(CYTHON_EXECUTABLES "${CYTHON_EXECUTABLE};${CYTHON_ROOT}/cython")
else()
  set(CYTHON_EXECUTABLES "${CYTHON_EXECUTABLE}")
endif()

message(STATUS "Looking for Cython among ${CYTHON_EXECUTABLES}")

set(Cython_FOUND FALSE)
foreach(cy_exe IN LISTS CYTHON_EXECUTABLES)
    message(status "Trying with ${cy_exe}")
    IF (cy_exe)
        # Try to run Cython, to make sure it works:
        execute_process(
            COMMAND ${cy_exe} "--version"
            RESULT_VARIABLE CYTHON_RESULT
            OUTPUT_VARIABLE cython_version
            ERROR_QUIET
            )
        if (CYTHON_RESULT EQUAL 0)
            # Only if cython exits with the return code 0, we know that all is ok:
            SET(Cython_FOUND TRUE)
            SET(Cython_Compilation_Failed FALSE)
            set(CYTHON_EXECUTABLE ${cy_exe})
            message(status "YAS! ${cy_exe} ${CYTHON_EXECUTABLE} ${cython_version}")
            break()
        else (CYTHON_RESULT EQUAL 0)
            SET(Cython_Compilation_Failed TRUE)
        endif (CYTHON_RESULT EQUAL 0)
    endif (cy_exe)
endforeach()




IF (Cython_FOUND)
	IF (NOT Cython_FIND_QUIETLY)
		MESSAGE(STATUS "Found CYTHON version ${cython_version}: ${CYTHON_EXECUTABLE}")
	ENDIF (NOT Cython_FIND_QUIETLY)
ELSE (Cython_FOUND)
    message(WARNING "Cython not found!")
	if (Cython_FIND_REQUIRED)
        if(Cython_Compilation_Failed)
            MESSAGE(STATUS "Found CYTHON: ${CYTHON_EXECUTABLE} But compilation failed")
			# On Win the testing of Cython does not return any accessible value, so the test is not carried out. Fresh Cython install was tested and works.
			IF(NOT MSVC)
				MESSAGE(FATAL_ERROR "Your Cython version is too old. Please upgrade Cython.")
			ENDIF(NOT MSVC)
        else(Cython_Compilation_Failed)
            MESSAGE(FATAL_ERROR "Could not find Cython. Please install Cython.")
        endif(Cython_Compilation_Failed)
	endif (Cython_FIND_REQUIRED)
endif (Cython_FOUND)

