#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'

# get our credentails + set region
credentials = Aws::SharedCredentials.new(profile_name: 'group3')
region = 'us-east-1'


# Get an ami instance based on image id
# @param image_id [String] Image ID (e.g, ami-1f677075)
# @param credentials [Aws::SharedCredentails] Credential Instance
# @param region [String] Region where AMI lives

def get_ami_by_image_id(image_id,region,credentials)

	# get an ec2 client
	ec2 = Aws::EC2::Client.new(
  		region: region,
  		credentials: credentials)

	# pull the ami description based on image id
	ec2_image_description = ec2.describe_image_attribute({
		image_id: image_id,
		attribute: "description"
	});
	
	return ec2_image_description
	
end

ami_response = get_ami_by_image_id('ami-1f677075',region,credentials)

puts ami_response.image_id

