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

SET(Cython_FOUND FALSE)
IF (CYTHON_EXECUTABLE)
    # Try to run Cython, to make sure it works:
    execute_process(
        COMMAND ${CYTHON_EXECUTABLE} "--version"
        RESULT_VARIABLE CYTHON_RESULT
        OUTPUT_QUIET
        ERROR_QUIET
        )
    if (CYTHON_RESULT EQUAL 0)
        # Only if cython exits with the return code 0, we know that all is ok:
        SET(Cython_FOUND TRUE)
        SET(Cython_Compilation_Failed FALSE)
    else (CYTHON_RESULT EQUAL 0)
        SET(Cython_Compilation_Failed TRUE)
    endif (CYTHON_RESULT EQUAL 0)
ENDIF (CYTHON_EXECUTABLE)


IF (Cython_FOUND)
	IF (NOT Cython_FIND_QUIETLY)
		MESSAGE(STATUS "Found CYTHON: ${CYTHON_EXECUTABLE}")
	ENDIF (NOT Cython_FIND_QUIETLY)
ELSE (Cython_FOUND)
	IF (Cython_FIND_REQUIRED)
        if(Cython_Compilation_Failed)
            MESSAGE(STATUS "Found CYTHON: ${CYTHON_EXECUTABLE}")
			# On Win the testing of Cython does not return any accessible value, so the test is not carried out. Fresh Cython install was tested and works.
			IF(NOT MSVC)
				MESSAGE(FATAL_ERROR "Your Cython version is too old. Please upgrade Cython.")
			ENDIF(NOT MSVC)
        else(Cython_Compilation_Failed)
            MESSAGE(FATAL_ERROR "Could not find Cython. Please install Cython.")
        endif(Cython_Compilation_Failed)
	ENDIF (Cython_FIND_REQUIRED)
ENDIF (Cython_FOUND)

