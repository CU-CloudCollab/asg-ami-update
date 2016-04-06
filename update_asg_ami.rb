#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'
require 'uuid'
require 'optparse'

def get_ami_by_image_id(image_id, region, credentials)

    ec2 = Aws::EC2::Client.new(
        region: region,
        credentials: credentials)

    # pull the ami description based on image id
    ec2_image_description = ec2.describe_image_attribute(image_id: image_id,
                                                         attribute: 'description')
    ec2_image_description
end

# given an autoscaling, return the launch configuration name
def get_launch_config_name(asg)
    asg.launch_configuration_name
end

# given a launch configuration (LC) name, get the LC options
def get_launch_config_hash(lcName, region, credentials)
    cli = Aws::AutoScaling::Client.new(region: region,
                                       credentials: credentials)

    lcd = cli.describe_launch_configurations(launch_configuration_names: [lcName])
    lc = lcd.launch_configurations[0]
    opt = { launch_configuration_name: lcName,
            block_device_mappings: [] }
    opt[:image_id] = lc.image_id if lc.image_id
    opt[:key_name] = lc.key_name if lc.key_name
    opt[:security_groups] = lc.security_groups if lc.security_groups
    opt[:classic_link_vpc_id] = lc.classic_link_vpc_id if lc.classic_link_vpc_id
		opt[:classic_link_vpc_security_groups] = lc.classic_link_vpc_security_groups if lc.classic_link_vpc_security_groups
    opt[:user_data] = lc.user_data if lc.user_data != ""
    opt[:instance_type] = lc.instance_type if lc.instance_type
    opt[:kernel_id] = lc.kernel_id if lc.kernel_id != ""
    opt[:ramdisk_id] = lc.ramdisk_id if lc.ramdisk_id != ""

    lc.block_device_mappings.each do |bdm|
        ebs = { delete_on_termination: false, encrypted: false }
        ebs[:snapshot_id] = bdm.ebs.snapshot_id if bdm.ebs.snapshot_id
        ebs[:volume_size] = bdm.ebs.volume_size if bdm.ebs.volume_size
        ebs[:volume_type] = bdm.ebs.volume_type if bdm.ebs.volume_type
				ebs[:delete_on_termination] = bdm.ebs.delete_on_termination if bdm.ebs.delete_on_termination
        ebs[:iops] = bdm.ebs.iops if bdm.ebs.iops
        ebs[:encrypted] = bdm.ebs.encrypted if bdm.ebs.encrypted

				nb = { device_name: bdm.device_name }
				nb[:virtual_name] = bdm.virtual_name if bdm.virtual_name
				# nb[:no_device] = true if bdm.no_device  #TODO: handle for condition where no_device=true
				nb[:ebs] = ebs

        opt[:block_device_mappings].push(nb)
    end

    opt[:instance_monitoring] = { enabled: false }
    opt[:instance_monitoring][:enabled] = true if lc.instance_monitoring.enabled
    opt[:spot_price] = lc.spot_price if lc.spot_price
		opt[:iam_instance_profile] = lc.iam_instance_profile if lc.iam_instance_profile
    opt[:ebs_optimized] = lc.ebs_optimized if lc.ebs_optimized
		opt[:associate_public_ip_address] = lc.associate_public_ip_address if lc.associate_public_ip_address
    opt[:placement_tenancy] = lc.placement_tenancy if lc.placement_tenancy

    opt
end

# given a group name, return the scaling group
def get_asg_by_name(groupName, region, credentials)
    cli = Aws::AutoScaling::Client.new(region: region,
                                       credentials: credentials)

    asg_desc = cli.describe_auto_scaling_groups(auto_scaling_group_names: [groupName])
    asg = asg_desc.auto_scaling_groups[0]

    asg
end

# create launch configuration from options hash provided
def create_launch_config_by_hash(lc_hash = {}, region, credentials)
		# Get autoscale client
    asg = Aws::AutoScaling::Client.new(region: region,
                                       credentials: credentials)

		# LC needs a new name
		uuid = UUID.new
		lc_hash[:launch_configuration_name] = "lc-" + uuid.generate

    # Pass our options hash to the client
    creation_response = asg.create_launch_configuration(lc_hash)

		return lc_hash[:launch_configuration_name]
end

def update_asg_launch_config(asg_name, lc_name, region, credentials)
    asg_client = Aws::AutoScaling::Client.new(credentials: credentials,
                                              region: region)

    update_asg = asg_client.update_auto_scaling_group(auto_scaling_group_name: asg_name,
                                                      launch_configuration_name: lc_name)
end

# example

credentials = Aws::SharedCredentials.new(profile_name: 'hackathon')
region = 'us-east-1'

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: update_asg_ami.rb [options]"

  opts.on("-g asg","--asg=asg","Autoscale Group Name") do |asg|
    options[:asg] = asg
  end

	opts.on("-i ami","--ami=ami","New AMI") do |ami|
    options[:ami] = ami
  end

	opts.on("-h", "--help", "Prints this help") do
  	puts opts
    exit
  end

end.parse!


options_defined = true
if options[:asg].nil?
	puts "Autoscale group name required"
	options_defined=false
end

if options[:ami].nil?
	puts "New AMI image id required"
	options_defined=false
end

# TODO: add validation to check if ASG and AMI exist before continuing

if options_defined

	asg = get_asg_by_name(options[:asg], region, credentials)
	existing_lc_name = get_launch_config_name(asg)
	new_lc_config_hash = get_launch_config_hash(existing_lc_name, region, credentials)
	new_lc_name = create_launch_config_by_hash(new_lc_config_hash, region, credentials)
	puts new_lc_name + " created"
	update_asg_launch_config(options[:asg],new_lc_name, region, credentials)
	puts "Updated ASG with new Launch Configuration"

end
