# this file is part of the Gadgetron repository
# dowloaded from https://github.com/gadgetron/gadgetron/commit/43dd980f5368776b58df2e211470cabeeabab745
# https://github.com/gadgetron/gadgetron/blob/master/cmake/FindACE.cmake
#
# The file is distributed with the following license:
#
# GADGETRON SOFTWARE LICENSE V1.0, NOVEMBER 2011
# 
# PERMISSION IS HEREBY GRANTED, FREE OF CHARGE, TO ANY PERSON OBTAINING
# A COPY OF THIS SOFTWARE AND ASSOCIATED DOCUMENTATION FILES (THE
# "SOFTWARE"), TO DEAL IN THE SOFTWARE WITHOUT RESTRICTION, INCLUDING
# WITHOUT LIMITATION THE RIGHTS TO USE, COPY, MODIFY, MERGE, PUBLISH,
# DISTRIBUTE, SUBLICENSE, AND/OR SELL COPIES OF THE SOFTWARE, AND TO
# PERMIT PERSONS TO WHOM THE SOFTWARE IS FURNISHED TO DO SO, SUBJECT TO
# THE FOLLOWING CONDITIONS:
# 
# THE ABOVE COPYRIGHT NOTICE, THIS PERMISSION NOTICE, AND THE LIMITATION
# OF LIABILITY BELOW SHALL BE INCLUDED IN ALL COPIES OR REDISTRIBUTIONS
# OF SUBSTANTIAL PORTIONS OF THE SOFTWARE.
# 
# SOFTWARE IS BEING DEVELOPED IN PART AT THE NATIONAL HEART, LUNG, AND BLOOD
# INSTITUTE, NATIONAL INSTITUTES OF HEALTH BY AN EMPLOYEE OF THE FEDERAL
# GOVERNMENT IN THE COURSE OF HIS OFFICIAL DUTIES. PURSUANT TO TITLE 17, 
# SECTION 105 OF THE UNITED STATES CODE, THIS SOFTWARE IS NOT SUBJECT TO 
# COPYRIGHT PROTECTION AND IS IN THE PUBLIC DOMAIN. EXCEPT AS CONTAINED IN
# THIS NOTICE, THE NAME OF THE AUTHORS, THE NATIONAL HEART, LUNG, AND BLOOD
# INSTITUTE (NHLBI), OR THE NATIONAL INSTITUTES OF HEALTH (NIH) MAY NOT 
# BE USED TO ENDORSE OR PROMOTE PRODUCTS DERIVED FROM THIS SOFTWARE WITHOUT 
# SPECIFIC PRIOR WRITTEN PERMISSION FROM THE NHLBI OR THE NIH.THE SOFTWARE IS 
# PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Find the ACE client includes and library
#

# This module defines
# ACE_INCLUDE_DIR, where to find ace.h
# ACE_LIBRARIES, the libraries to link against ... !! NOT header is old !! ...
# ACE_FOUND, if false, you cannot build anything that requires ACE

# This is the new header...

######################################################################## 
## check pkg-config for ace information, if available 
 
set(ACE_INCLUDE_DIR_GUESS) 
set(ACE_LIBRARY_DIR_GUESS) 
set(ACE_LINK_FLAGS) 
if(PKGCONFIG_EXECUTABLE) 
	PKGCONFIG(ace ACE_INCLUDE_DIR_GUESS ACE_LIBRARY_DIR_GUESS ACE_LINK_FLAGS ACE_C_FLAGS) 
	if (NOT ACE_LINK_FLAGS) 
		PKGCONFIG(ACE ACE_INCLUDE_DIR_GUESS ACE_LIBRARY_DIR_GUESS ACE_LINK_FLAGS ACE_C_FLAGS) 
	endif () 
	add_definitions(${ACE_C_FLAGS}) 
endif() 
 
set(ACE_LINK_FLAGS "${ACE_LINK_FLAGS}" CACHE INTERNAL "ace link flags") 
 
######################################################################## 
##  general find 
 
find_path(ACE_INCLUDE_DIR ace/ACE.h ${CMAKE_SOURCE_DIR}/../ACE_wrappers/ /usr/include /usr/local/include $ENV{ACE_ROOT} $ENV{ACE_ROOT}/include DOC "directory containing ace/*.h for ACE library") 
 
# in YARP1, config was in another directory 
set(ACE_INCLUDE_CONFIG_DIR "" CACHE STRING "location of ace/config.h") 
mark_as_advanced(ACE_INCLUDE_CONFIG_DIR) 
 
find_library(ACE_LIBRARY NAMES ACE ace PATHS ${CMAKE_SOURCE_DIR}/../ACE_wrappers/lib/ /usr/lib /usr/local/lib $ENV{ACE_ROOT}/lib $ENV{ACE_ROOT} DOC "ACE library file") 
 
if (WIN32 AND NOT CYGWIN) 
	set(CMAKE_DEBUG_POSTFIX "d") 
	find_library(ACE_DEBUG_LIBRARY NAMES ACE${CMAKE_DEBUG_POSTFIX} ace${CMAKE_DEBUG_POSTFIX} PATHS ${CMAKE_SOURCE_DIR}/../ACE_wrappers/lib/ /usr/lib /usr/local/lib $ENV{ACE_ROOT}/lib $ENV{ACE_ROOT} DOC "ACE library file (debug version)") 
endif () 
 
 
######################################################################## 
## OS-specific extra linkage 
 
# Solaris needs some extra libraries that may not have been found already 
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS") 
  #message(STATUS "need to link solaris-specific libraries") 
  #  link_libraries(socket rt) 
  set(ACE_LIBRARY ${ACE_LIBRARY} socket rt nsl) 
endif() 
 
# Windows needs some extra libraries 
if (WIN32 AND NOT CYGWIN) 
  #message(STATUS "need to link windows-specific libraries") 
  #link_libraries(winmm) 
  set(ACE_LIBRARY ${ACE_LIBRARY} winmm) 
endif () 
 
 
######################################################################## 
## finished - now just set up flags and complain to user if necessary 
 
if (ACE_INCLUDE_DIR AND ACE_LIBRARY) 
	set(ACE_FOUND TRUE) 
else () 
	set(ACE_FOUND FALSE) 
endif () 
 
if (ACE_DEBUG_LIBRARY) 
	set(ACE_DEBUG_FOUND TRUE) 
else ()
  set(ACE_DEBUG_LIBRARY ${ACE_LIBRARY})
endif () 
 
if (ACE_FOUND) 
	if (NOT Ace_FIND_QUIETLY) 
		message(STATUS "Found ACE library: ${ACE_LIBRARY}") 
		message(STATUS "Found ACE include: ${ACE_INCLUDE_DIR}") 
	endif () 
else () 
	if (Ace_FIND_REQUIRED) 
		message(FATAL_ERROR "Could not find ACE") 
	endif () 
endif () 

# TSS: backwards compatibility
set(ACE_LIBRARIES ${ACE_LIBRARY}) 
