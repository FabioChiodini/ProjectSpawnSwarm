# ProjectSpawnSwarm
Project to spawn Web servers using Docker Machine Swarm and Consul

This creates
one VM with Consul in Docker

Two VMs as "slaves"

One Vm hosting the Docker swarm in a Docker container


It then starts a Docker Container (nginx) via Docker Swarm



It uses a file to load the variables needed (/home/ec2-user/Cloud1).

This file has the following format:

export K1_AWS_ACCESS_KEY=AKXXXXXX

export K1_AWS_SECRET_KEY=LXXXXXXXXXX

export K1_AWS_VPC_ID=vpc-XXXXXX

export K1_AWS_ZONE=b

export K1_AWS_DEFAULT_REGION=us-east-1

export AWS_DEFAULT_REGION=us-east-1

The first five variable are used by the docker-machine command, the last one is used by aws cli (to edit the security group)
