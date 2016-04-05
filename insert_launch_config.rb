#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'

# get our credentails + set region
credentials = Aws::SharedCredentials.new(profile_name: 'group3')
region = 'us-east-1'

#create client
ASG_client  = Aws::AutoScaling::Client.new(credentials: credentials, region: 'us-east-1')

#update auto scaling group
update_ASG = ASG_client.update_auto_scaling_group({
  auto_scaling_group_name: "ResourceName",
  launch_configuration_name: "ResourceName",
})


