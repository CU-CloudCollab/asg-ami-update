#!/usr/bin/env ruby
require 'cucloud'
require 'optparse'

asg_utils = Cucloud::AsgUtils.new

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: update_asg_ami.rb [options]'

  opts.on('-g asg', '--asg=asg', 'Autoscale Group Name') do |asg|
    options[:asg] = asg
  end

  opts.on('-i ami', '--ami=ami', 'New AMI') do |ami|
    options[:ami] = ami
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

options_defined = true
if options[:asg].nil?
  puts 'Autoscale group name required'
  options_defined = false
end

if options[:ami].nil?
  puts 'New AMI image id required'
  options_defined = false
end

# TODO: add validation to check if ASG and AMI exist before continuing

if options_defined

  # get scaling group and create new launch configuration request hash
  asg = asg_utils.get_asg_by_name(options[:asg])
  existing_lc = asg_utils.get_launch_configuration_by_name(asg.launch_configuration_name)
  new_lc_options = asg_utils.generate_lc_options_hash_with_ami(existing_lc, options[:ami])

  asg_utils.create_launch_configuration(new_lc_options)
  puts "New launch configuration created: #{new_lc_options[:launch_configuration_name]}," \
  " AMI: #{new_lc_options[:image_id]}"

  asg_utils.update_asg_launch_configuration!(options[:asg], new_lc_options[:launch_configuration_name])
  puts "Autoscaling group '#{options[:asg]}' updated with new launch configuration"

end
