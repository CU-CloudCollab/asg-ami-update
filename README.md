# Autoscale AMI Updater

## Purpose

This utility provides a command-line interface to update the AMI associated with an autoscale group.  This functionality is available in the AWS web interface (copy launch configuration), but not in the SDKs.

Given an autoscale group name and an AMI id, the utility uses the cucloud library to:

1. looks up the launch configuration currently associated with the autoscale group.
2. copies the existing launch configuration (they are immutable) and replaces the AMI with the provided image id
3. creates a new launch configuration (uniquely named with uuid)
4. updates the autoscale group with the new launch configuration

## Use

The underlying cucloud library (cucloud gem) assumes you have a local AWS environment configured (see https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs).  It also currently assumes you are in the us-east region.

From command line:

``` bundle install ```

``` bundle exec update_asg_ami.rb -g [existing scaling group name] -i [desired AMI image id]```

You should see a note with the new launch configuration name as well and a note that the ASG update was successful.


## History

* This initial proof of concept was developed at the 4/5/2016 AWS Hackathon by team 3 (bmh67, dp462, and sjm34).  
* Code has since been refactored and integrated into the cucloud ruby library (7/10/2016).

