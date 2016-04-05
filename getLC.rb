#!/usr/bin/ruby
require 'rubygems'
require 'aws-sdk'

# given an autoscaling, return the launch configuration name
def getLC(asg, region, credentials)

   return asg.launch_configuration_name
end

#given a group name, return the scaling group
def getASG(groupName, region, credentials)
   asg_cli = Aws::AutoScaling::Client.new(region: region,
      credentials: credentials)

   asg_desc = asg_cli.describe_auto_scaling_groups({auto_scaling_group_names: ["group-3-sg-1"]})
   asg = asg_desc.auto_scaling_groups[0]
   return asg
end


region = 'us-east-1'
credentials = Aws::SharedCredentials.new(profile_name: 'group3')

asg = getASG("group-3-sg-1", region, credentials)
print asg.auto_scaling_group_arn + "\n"
print getLC(asg) + "\n"

#lc = getLC(asg, region, credentials)

