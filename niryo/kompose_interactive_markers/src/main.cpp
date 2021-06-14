#include <iostream>

#include <moveit/common_planning_interface_objects/common_objects.h>
#include <moveit/robot_interaction/robot_interaction.h>

#include <moveit/planning_scene_monitor/planning_scene_monitor.h>
#include <moveit/planning_interface/planning_interface.h>
#include <moveit/robot_interaction/interaction_handler.h>
#include <moveit/robot_interaction/robot_interaction.h>
#include <moveit/robot_interaction/kinematic_options.h>
#include <moveit/robot_state/conversions.h>
#include <moveit/robot_interaction/kinematic_options_map.h>
#include <moveit/robot_model_loader/robot_model_loader.h>
#include <moveit/move_group_interface/move_group_interface.h>

class KomposeInteraction
{
public:
    KomposeInteraction(ros::NodeHandle& nh, const std::string& joint_group, const std::string& description = "robot_description") :
        m_loader(description, true),
        m_joint_group_name(joint_group),
        m_move_group(joint_group)
    {
        m_goal_robot_state_pub = nh.advertise<moveit_msgs::RobotState>("/kompose/current_goal_state", 5, /*latch=*/true);
        ROS_INFO_STREAM("Description loading from: " << description);
        ROS_INFO_STREAM("Joint group name: " << m_joint_group_name);

        // planning interface
        std::shared_ptr<tf2_ros::Buffer> tf_buffer = moveit::planning_interface::getSharedTF();
        m_planning_scene_monitor.reset(new planning_scene_monitor::PlanningSceneMonitor(description, tf_buffer, "kompose_planning_scene_monitor"));
        ROS_INFO_STREAM("Robot model loader activated...");
        auto model = m_loader.getModel();
        ROS_INFO_STREAM("Robot LOADED");
        m_robot_interaction.reset(new robot_interaction::RobotInteraction(m_loader.getModel(), "kompose_motion_planning_display"));
        robot_interaction::KinematicOptions o;

        m_robot_interaction->getKinematicOptionsMap()->setOptions(
            robot_interaction::KinematicOptionsMap::ALL, o, robot_interaction::KinematicOptions::STATE_VALIDITY_CALLBACK);
        // m_query_robot_start->load(*model->getURDF());
        // m_query_robot_goal->load(*model->getURDF());

        robot_state::RobotStatePtr ks(new robot_state::RobotState(m_planning_scene_monitor->getPlanningScene()->getCurrentState()));
        m_query_start_state.reset(new robot_interaction::InteractionHandler(m_robot_interaction, "start", *ks,
                                                                           m_planning_scene_monitor->getTFClient()));
        m_query_goal_state.reset(new robot_interaction::InteractionHandler(m_robot_interaction, "goal", *ks,
                                                                          m_planning_scene_monitor->getTFClient()));

        m_robot_interaction->decideActiveComponents(joint_group);
        m_query_start_state->setUpdateCallback(boost::bind(&KomposeInteraction::update, this, _1, _2));
        m_query_goal_state->setUpdateCallback(boost::bind(&KomposeInteraction::update, this, _1, _2));
        m_robot_interaction->addInteractiveMarkers(m_query_goal_state, 0.15);

        m_goal_robot_sub = nh.subscribe("/kompose/update_goal_state", 10, &KomposeInteraction::setGoalRobotState, this);
        m_move_sub = nh.subscribe("/kompose/move", 10, &KomposeInteraction::move, this);
        m_plan_sub = nh.subscribe("/kompose/plan", 10, &KomposeInteraction::plan, this);

        publishMarkers(true);
    }

    void publishMarkers(bool need_update) {
        if (m_robot_interaction)
        {
            if (need_update)
            {
                m_robot_interaction->updateInteractiveMarkers(m_query_goal_state);
            }
            else
            {
                m_robot_interaction->publishInteractiveMarkers();
            }
        }
    }

    void setGoalRobotState(const moveit_msgs::RobotState& msg) {
        moveit::core::RobotState state(*m_query_goal_state->getState());
        moveit::core::robotStateMsgToRobotState(msg, state, false);
        m_query_goal_state->setState(state);
        publishMarkers(true);
    }

    void update(robot_interaction::InteractionHandler* handler, bool error_state_changed)
    {
        publishMarkers(!error_state_changed);
        moveit_msgs::RobotState msg;
        moveit::core::robotStateToRobotStateMsg(*(handler->getState()), msg, false);
        m_goal_robot_state_pub.publish(msg);
    }

    void move(const moveit_msgs::RobotState& msg) {
        // using random state to copy from, somehow there is no default constructor for robotstate
        ROS_WARN("Moving to robot state...");
        moveit::core::RobotState state(m_loader.getModel());
        moveit::core::robotStateMsgToRobotState(msg, state, false);
        m_move_group.setJointValueTarget(state);
        m_move_group.asyncMove();
        ROS_WARN("Returning from move");
    }

    void plan(const moveit_msgs::RobotState& msg) {
        ROS_WARN("Planning to robot state...");
        moveit::core::RobotState state(m_loader.getModel());
        moveit::core::robotStateMsgToRobotState(msg, state, false);
        m_move_group.setJointValueTarget(state);
        moveit::planning_interface::MoveGroupInterface::Plan move_plan;
        m_move_group.plan(move_plan);
        ROS_WARN("Returning from plan");
    }

private:
    robot_interaction::RobotInteractionPtr m_robot_interaction;
    robot_interaction::InteractionHandlerPtr m_handler;
    robot_model_loader::RobotModelLoader m_loader;
    robot_interaction::InteractionHandlerPtr m_query_start_state, m_query_goal_state;

    planning_scene_monitor::PlanningSceneMonitorPtr m_planning_scene_monitor;
    std::string m_joint_group_name;

    moveit::planning_interface::MoveGroupInterface m_move_group;

    ros::Subscriber m_goal_robot_sub, m_move_sub, m_plan_sub;
    ros::Publisher m_goal_robot_state_pub;
};

int main(int argc, char** argv) {
    ros::init(argc, argv, "kompose_interactive_markers");
    ros::NodeHandle nh("imk");

    ros::AsyncSpinner spinner(2);
    spinner.start();

    std::string jg;
    nh.getParam("joint_group", jg);
    KomposeInteraction interaction(nh, jg);

    ros::Rate r(2);
    while (ros::ok())
    {
        interaction.publishMarkers(false);
        r.sleep();
    }

    return 0;
}