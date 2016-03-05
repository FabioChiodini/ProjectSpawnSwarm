NC='\033[0m'              #No Color  
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White


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

#Launches a remote Consul instance

docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap


echo ----
echo ${RED} Consul RUNNING ON $publicipCONSULK ${NC}
echo publicipCONSULK=$publicipCONSULK
echo ----

#Jonas Style Launch Swarm

#Launches another temporary container

#docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION localK

#Connects to Container
#docker-machine env localK > /home/ec2-user/localK
#. /home/ec2-user/localK

#Creates swarm ID and stores it into file and variable
docker run swarm create > /home/ec2-user/kiodo1
tail -1 /home/ec2-user/kiodo1 > /home/ec2-user/SwarmToken

SwarmTokenK=$(cat /home/ec2-user/SwarmToken)

echo ----
echo Check swarm token on https://discovery.hub.docker.com/v1/clusters/$SwarmTokenK
echo ----

#Create Swarm Master
docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION --swarm --swarm-master --swarm-discovery token://$SwarmTokenK swarm-master

#Opens Firewall Port for Docker SWARM
aws ec2 authorize-security-group-ingress --group-name docker-machine --protocol tcp --port 8333 --cidr 0.0.0.0/0

#Connects to remote VM
docker-machine env swarm-master > /home/ec2-user/SWARM1
. /home/ec2-user/SWARM1

publicipSWARMK=$(docker-machine ip swarm-master)


echo ----
echo SWARM  RUNNING ON $publicipSWARMK
echo publicipSWARMK=$publicipSWARMK
echo Consul RUNNING ON $publicipCONSULK
echo ----


#Prepares one VM to be joined to SWARM Cluster

#Spawns VM with UUID
UUIDK1=$(cat /proc/sys/kernel/random/uuid)


docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION --swarm --swarm-discovery token://$SwarmTokenK SPAWN-$UUIDK1 

#Stores ip of the VM
docker-machine env SPAWN-$UUIDK1 > /home/ec2-user/Docker1
. /home/ec2-user/Docker1

publicipK1=$(docker-machine ip SPAWN-$UUIDK1)
echo ----
echo Machine $publicipK1 connected to SWARM
echo ----




#Spawns VM2 with new UUID
UUIDK2=$(cat /proc/sys/kernel/random/uuid)

#docker-machine create --driver amazonec2
docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION --swarm --swarm-discovery token://$SwarmTokenK SPAWN-$UUIDK2

docker-machine env SPAWN-$UUIDK2 > /home/ec2-user/Docker2
. /home/ec2-user/Docker2

publicipK2=$(docker-machine ip SPAWN-$UUIDK2)

echo ----
echo Second Slave RUNNING ON $publicipK2
echo ----


#Launches a Container using SWARM

eval $(docker-machine env --swarm swarm-master)

docker run -d --name www -p 80:80 nginx



echo run eval $(docker-machine env --swarm swarm-master) TO connect to the cluster
echo THEN run docker info TO check swarm status
echo RUN docker ps TO check which containers are running

#Optionally close all non useful ports

#KILLS SWARM (Testing purposes cleanup)
docker-machine rm swarm-master
docker-machine rm SPAWN-CONSUL
docker-machine rm SPAWN-$UUIDK1
docker-machine rm SPAWN-$UUIDK2



#Displays Public IP


