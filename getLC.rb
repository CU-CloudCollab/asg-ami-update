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

   opt = {launch_configuration_name: lcName,
          block_device_mappings: []}
   if (lc.image_id)
      opt[:image_id] = lc.image_id
   end
   if (lc.key_name )
      opt[:key_name] = lc.key_name
   end
   if (lc.security_groups )
      opt[:security_groups] = lc.security_groups
   end
   if (lc.classic_link_vpc_id )
      opt[:classic_link_vpc_id] = lc.classic_link_vpc_id
   end
   if (lc.classic_link_vpc_security_groups )
      opt[:classic_link_vpc_security_groups] = lc.classic_link_vpc_security_groups
   end
   if (lc.user_data )
      opt[:user_data] = lc.user_data
   end
   if (lc.instance_type )
      opt[:instance_type] = lc.instance_type
   end
   if (lc.kernel_id )
      opt[:kernel_id] = lc.kernel_id
   end
   if (lc.ramdisk_id )
      opt[:ramdisk_id] = lc.ramdisk_id
   end
   lc.block_device_mappings.each { 
      |bdm|
      nb = {device_name: bdm.device_name, no_device: false }
      ebs = {delete_on_termination: false, encrypted: false}
      if (bdm.virtual_name)
         nb[:virtual_name] = bdm.virtual_name
      end
      if (bdm.no_device)
         nb[:no_device] = true
      end 
      if (bdm.ebs.snapshot_id)
         ebs[:snapshot_id] = bdm.ebs.snapshot_id
      end
      if (bdm.ebs.volume_size)
         ebs[:volume_size] = bdm.ebs.volume_size
      end
      if (bdm.ebs.volume_type)
         ebs[:volume_type] = bdm.edm.volume_type
      end
      if (bdm.ebs.delete_on_termination)
         ebs[:delete_on_termination] = bdm.ebs.delete_on_termination
      end
      if (bdm.ebs.iops)
         ebs[:iops] = bdm.ebs.iops
      end
      if (bdm.ebs.encryped)
         ebs[:encrypted] = bdm.ebs.encryped
      end
      nb[:ebs] = ebs
      opt[:block_device_mappings].push(nb)
   }
   opt[:instance_monitoring] = {enabled: false}
   if (lc.instance_monitoring.enabled )
      opt[:instance_monitoring][:enabled] = true
   end
   if (lc.spot_price )
      opt[:spot_price] = lc.spot_price
   end
   if (lc.iam_instance_profile )
      opt[:iam_instance_profile] = lc.iam_instance_profile
   end
   if (lc.ebs_optimized )
      opt[:ebs_optimized] = lc.ebs_optimized
   end
   if (lc.associate_public_ip_address )
      opt[:associate_public_ip_address] = lc.associate_public_ip_address
   end
   if (lc.placement_tenancy )
      opt[:placement_tenancy] = lc.placement_tenancy
   end

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


