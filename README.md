# ProjectSpawnSwarm
Project to spawn Web servers using Docker Machine, Docker Swarm and Docker Discovery (Consul still TBI)

Tested on a t1.micro AMI

To install the prerequisites on an AMI image use this:

https://github.com/FabioChiodini/AWSDockermachine


This script creates:
one VM with Consul in Docker (used also to prepare docker Discovery)

One VM hosting the Docker swarm in a Docker container

A number of VMs (specified in the variable export InstancesK) as "slaves"


It then starts many Docker Containers (nginx) via Docker Swarm (the numbert of instances is specified in the variable export InstancesK)

It also opens up all required port on AWS Security Groups

It uses a file to load the variables needed (/home/ec2-user/Cloud1).

This file has the following format:

export K1_AWS_ACCESS_KEY=AKXXXXXX

export K1_AWS_SECRET_KEY=LXXXXXXXXXX

export K1_AWS_VPC_ID=vpc-XXXXXX

export K1_AWS_ZONE=b

export K1_AWS_DEFAULT_REGION=us-east-1

export AWS_DEFAULT_REGION=us-east-1

export VM-InstancesK=2
export Container-InstancesK=3

The first five variable are used by the docker-machine command, the export AWS_DEFAULT_REGION variable is used by AWS cli (to edit the security group) and the the last two are used to determine the VM/Containers instances to run


@FabioChiodini
