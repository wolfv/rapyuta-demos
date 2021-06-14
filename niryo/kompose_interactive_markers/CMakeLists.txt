cmake_minimum_required(VERSION 2.8.3)
project(kompose_interactive_markers)
find_package(
	catkin REQUIRED
	COMPONENTS
	moveit_ros_robot_interaction
   moveit_ros_planning_interface
)

catkin_package(
   INCLUDE_DIRS
   LIBRARIES
   	moveit_ros_robot_interaction
   CATKIN_DEPENDS
   DEPENDS
   	moveit_ros_robot_interaction
      moveit_core
      moveit_ros_planning
)

include_directories(${catkin_INCLUDE_DIRS})

add_executable(imk src/main.cpp)
target_link_libraries(imk ${catkin_LIBRARIES})

# message(${catkin_LIBRARIES})

install(TARGETS imk
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})
