
if(WIN32)
  # TODO: would be better to use a variable but for some reason KT cannot pass the variable to the execute_process
  # without strange error messages of b2
  
  execute_process(COMMAND ./b2 --with-system --with-filesystem --with-thread --with-program_options --with-chrono --with-date_time --with-atomic  --with-timer install --prefix=${BOOST_INSTALL_DIR}
    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE build_result)

else(WIN32)
  # selection of libraries has happened in the configure step
  execute_process(COMMAND ./b2 install
    WORKING_DIRECTORY ${BUILD_DIR} RESULT_VARIABLE build_result)

endif(WIN32)

return(${build_result})
