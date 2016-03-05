# ProjectSpawnSwarm
Project to spawn Web servers using Docker Machine, Docker Swarm and Docker Discovery (Consul still TBI)

To install the prerequisites on an AMI image use this:

https://github.com/FabioChiodini/AWSDockermachine


This script creates:
one VM with Consul in Docker (used also to prepare docker Discovery)

One VM hosting the Docker swarm in a Docker container

Two VMs as "slaves"


It then starts a Docker Container (nginx) via Docker Swarm

It also opens up all required port on AWS Security Groups

It uses a file to load the variables needed (/home/ec2-user/Cloud1).

This file has the following format:

export K1_AWS_ACCESS_KEY=AKXXXXXX

export K1_AWS_SECRET_KEY=LXXXXXXXXXX

export K1_AWS_VPC_ID=vpc-XXXXXX

export K1_AWS_ZONE=b

export K1_AWS_DEFAULT_REGION=us-east-1

export AWS_DEFAULT_REGION=us-east-1

The first five variable are used by the docker-machine command, the last one is used by AWS cli (to edit the security group)
