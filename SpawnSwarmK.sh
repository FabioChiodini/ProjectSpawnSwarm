#Load Env variables from File (maybe change to DB)
#using /home/ec2-user/Cloud1
#source /home/ec2-user/Cloud1
. /home/ec2-user/Cloud1

printenv AWS_SECRET_KEY

printenv AWS_VPC_ID


#Create Docker Consul VM 
docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION SPAWN-CONSUL

#Opens Firewall Port for Consul
aws ec2 authorize-security-group-ingress --group-name docker-machine --protocol tcp --port 8500 --cidr 0.0.0.0/0

#Connects to remote VM

docker-machine env SPAWN-CONSUL > /home/ec2-user/CONSUL1
. /home/ec2-user/CONSUL1

publicipCONSULK=$(docker-machine ip SPAWN-CONSUL)

#Launches a remore Consul instance

docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap


echo ----
echo Consul RUNNING ON $publicipCONSULK
echo publicipCONSULK=$publicipCONSULK
echo ----


#Prepares one VM to be joined to SWARM Cluster

#Spawns VM with UUID
UUIDK=$(cat /proc/sys/kernel/random/uuid)

#docker-machine create --driver amazonec2
docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION SPAWN-$UUIDK

docker-machine env SPAWN-$UUIDK > /home/ec2-user/Docker1
. /home/ec2-user/Docker1

publicipK1=$(docker-machine ip SPAWN-$UUIDK)

#Launches a Container to join the VM to a SWARM Cluster
docker run -d swarm join --addr=$publicipK1:2376 consul://$publicipCONSULK:8500/swarm


#Create Docker SWARM VM
docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION SPAWN-SWARM

#Connects to remote VM

docker-machine env SPAWN-SWARM > /home/ec2-user/SWARM1
. /home/ec2-user/SWARM1

publicipSWARMK=$(docker-machine ip SPAWN-SWARM)

#Prepares SWARM Manager

docker run -d -p 8333:2376 swarm manage consul://$publicipCONSULK:8500/swarm


echo ----
echo SWARM  RUNNING ON $publicipSWARMK
echo publicipSWARMK=$publicipSWARMK
echo ----

#Launches a Container using SWARM

docker -H tcp://$publicipSWARMK:8333 run -d --name www -p 80:80 nginx

echo Connect to $publicipSWARMK Port 80

#KILLS SWARM (Testing purposes)
docker-machine rm SPAWN-SWARM
docker-machine rm SPAWN-CONSUL
docker-machine rm SPAWN-$UUIDK


#Spawns VM with UUID
UUIDK=$(cat /proc/sys/kernel/random/uuid)

#docker-machine create --driver amazonec2 
docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION SPAWN-$UUIDK


echo ---
echo VM SPAWN-$UUIDK CREATED
echo ---

#Open port 80 on VM
aws ec2 authorize-security-group-ingress --group-name docker-machine --protocol tcp --port 80 --cidr 0.0.0.0/0

#Creates a docker container remotely
#docker-machine env SPAWN-$UUIDK
#eval $(docker-machine env SPAWN-$UUIDK)
#eval $(docker-machine env)
docker-machine env SPAWN-$UUIDK > /home/ec2-user/Docker1
. /home/ec2-user/Docker1

docker run -d --name docker-nginx -p 80:80 nginx

publicipK=$(docker-machine ip SPAWN-$UUIDK)

echo ----
echo connect to Public IP
echo publicipK=$publicipK
echo ----



#Gets rid of VM
#Waits for a Y (to check if all is good)
docker-machine rm SPAWN-$UUIDK


#Displays Public IP


