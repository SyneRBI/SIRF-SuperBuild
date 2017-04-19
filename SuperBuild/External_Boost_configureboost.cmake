if(WIN32)
  execute_process(COMMAND bootstrap.bat
    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE bootstrap_result)
else(WIN32)
  execute_process(COMMAND ./bootstrap.sh --prefix=${BOOST_INSTALL_DIR}
    --with-libraries=system,filesystem,thread,program_options,chrono,date_time,atomic,timer,regex,python
    #--with-libraries=system,thread,program_options,log,math...
    #--without-libraries=atomic...

    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE bootsrap_result)

endif(WIN32)

return(${bootstrap_result})
