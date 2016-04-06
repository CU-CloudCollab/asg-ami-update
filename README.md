# Autoscale AMI Updater

## Background/Purpose

The intention of this tool is to provide a set of functions and a simple command line interface to update the AMI associated with
an existing autoscaling group.  It extracts the launch configuration associated with the current autoscaling group, creates a new copy (named with a UUID) replacing only the image_id with the specified AMI, then updates the original autoscaling group with the new launch configuration.

This initial proof of concept was developed at the 4/5/2016 AWS Hackathon by team 3 (bmh67, dp462, and sjm34)

## Use

`update_asg_ami.rb -g [existing scaling group] -i [desired AMI image id]`


## Todo/Next Steps

Better validation of specified scaling group and ami (do they exist, do we have access to launch)

Refactor into the cucloud ruby spec/library

Test with a variety of launch configurations -- currently only tested with very simple cases.
