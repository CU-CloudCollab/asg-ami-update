#!/usr/bin/ruby
require 'rubygems'
require 'aws-sdk'

# given an autoscaling, return the launch configuration name
def getLCName(asg)
   return asg.launch_configuration_name
end

# given a launch configuration (LC) name, get the LC options 
def getLC(lcName, region, credentials)
   cli = Aws::AutoScaling::Client.new(region: region,
      credentials: credentials)

   lcd = cli.describe_launch_configurations({
      launch_configuration_names: [lcName]})
   lc = lcd.launch_configurations[0]

   opt = {
      launch_configuration_name: lcName,
      image_id: lc.image_id ,
      key_name: lc.key_name ,
      security_groups: lc.security_groups ,
      classic_link_vpc_id: lc.classic_link_vpc_id ,
      classic_link_vpc_security_groups: lc.classic_link_vpc_security_groups ,
      user_data: lc.user_data,
      instance_type: lc.instance_type,
      kernel_id: lc.kernel_id,
      ramdisk_id: lc.ramdisk_id,
      block_device_mappings: lc.block_device_mappings,
      instance_monitoring: {
        enabled: lc.instance_monitoring.enabled,
      },
      spot_price: lc.spot_price,
      iam_instance_profile: lc.iam_instance_profile,
      ebs_optimized: lc.ebs_optimized,
      associate_public_ip_address: lc.associate_public_ip_address,
      placement_tenancy: lc.placement_tenancy
   }
   return opt
end


#given a group name, return the scaling group
def getASG(groupName, region, credentials)
   cli = Aws::AutoScaling::Client.new(region: region,
      credentials: credentials)

   asg_desc = cli.describe_auto_scaling_groups({auto_scaling_group_names: [groupName]})
   asg = asg_desc.auto_scaling_groups[0]
   return asg
end


region = 'us-east-1'
credentials = Aws::SharedCredentials.new(profile_name: 'group3')

#sample code
asg = getASG("group-3-sg-1", region, credentials)
print asg.auto_scaling_group_arn + "\n"
lcName = getLCName(asg)
print lcName + "\n"
lc = getLC(lcName, region, credentials) 
print lc[:image_id] + "\n"


