#!/bin/bash
# created: 05-sep-2020 05:00PM (GMT)

# objective:
# The following script simulates the creation of a google cloud
# VPC network in custom mode with basic firewall rules.
# Also the creation of a virtual machine within the vpc's
# subnet (us-central1 region) is made to test setup.

read -p "Enter project ID: " project_ID
read -p "Enter vpc network name: " vpc_custom_net

# create a custom vpc network
echo "creating a custom vpc network..."
gcloud compute networks create $vpc_custom_net --project=$project_ID \
--subnet-mode=custom --bgp-routing-mode=regional

# create subnetwork for custom vpc network created
# using a CIDR range of 10.150.0.0/20
read -p "Enter name of subnetwork to create: " vpc_custom_subnet_us
echo "creating subnetwork $vpc_custom_subnet_us in $vpc_custom_net ..."
gcloud compute networks subnets create $vpc_custom_subnet_us --project=$project_ID \
--range=10.150.0.0/20 --network=$vpc_custom_net --region=us-central1

# create firewall rules to allow ping(ICMP), ssh
# and rdp connections to instances in the network
# **NOTE: CIDR range should be modified to allow selected range(s)**
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS \
--priority=1000 --network=$vpc_custom_net --action=ALLOW --rules=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0

# view the exitsting firewall rules 
gcloud compute firewall-rules list --sort-by=NETWORK

# create a vm to utilize the created vpc network
gcloud compute instances create vpc-custom-net-vm --zone=us-central1-c --project=$project_ID \
--machine-type=f1-micro --subnet=$vpc_custom_subnet_us
