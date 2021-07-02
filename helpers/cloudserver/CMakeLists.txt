cmake_minimum_required(VERSION 2.8.3)
project(cloudserver)

find_package(catkin REQUIRED)

catkin_python_setup()

catkin_package()

catkin_install_python(PROGRAMS
  scripts/run_cloudserver
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

# install(FILES
#   ... .launch files
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/launch
# )

# if (CATKIN_ENABLE_TESTING)
#   find_package(rostest REQUIRED)
#   add_rostest(test/websocket/test_smoke.test)
# endif()