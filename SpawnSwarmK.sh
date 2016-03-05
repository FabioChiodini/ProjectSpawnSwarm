
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
echo Consul RUNNING ON $publicipCONSULK
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
echo "$(tput setaf 1) Check swarm token on https://discovery.hub.docker.com/v1/clusters/$SwarmTokenK $(tput sgr 0)"
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
echo "$(tput setaf 1) SWARM  RUNNING ON $publicipSWARMK $(tput sgr 0)"
echo publicipSWARMK=$publicipSWARMK
echo Consul RUNNING ON $publicipCONSULK
echo ----

#Loops for creating Swarm nodes
#Starts #VM-InstancesK VMs using Docker machine and connects them to Swarm

i=0
while [ $i -lt $VM-InstancesK ]
do
    echo "output: $i"
    UUIDK=$(cat /proc/sys/kernel/random/uuid)
    echo Provisioning VM SPAWN$i-$UUIDK
    docker-machine create --driver amazonec2 --amazonec2-access-key $K1_AWS_ACCESS_KEY --amazonec2-secret-key $K1_AWS_SECRET_KEY --amazonec2-vpc-id  $K1_AWS_VPC_ID --amazonec2-zone $K1_AWS_ZONE --amazonec2-region $K1_AWS_DEFAULT_REGION --swarm --swarm-discovery token://$SwarmTokenK SPAWN$i-$UUIDK

    #Stores ip of the VM
    docker-machine env SPAWN$i-$UUIDK > /home/ec2-user/Docker$i
    . /home/ec2-user/Docker$i

    publicipK=$(docker-machine ip SPAWN$i-$UUIDK)
    echo ----
    echo "$(tput setaf 1) Machine $publicipK connected to SWARM $(tput sgr 0)"
    echo ----
    true $(( i++ ))
done


#Launches $instancesK Containers using SWARM


eval $(docker-machine env --swarm swarm-master)

i=0
while [ $i -lt $Container-InstancesK ]
do
    echo "output: $i"
    UUIDK=$(cat /proc/sys/kernel/random/uuid)
    echo Provisioning Container $i
    docker run -d --name www-$i -p 80:80 nginx
    true $(( i++ ))
done


docker ps

stringk=$(eval $(docker-machine env --swarm swarm-master))

echo ----
echo "$(tput setaf 1) SWARM  RUNNING ON $publicipSWARMK $(tput sgr 0)"
echo "$(tput setaf 1) run $stringK TO connect to the cluster $(tput sgr 0)"
echo THEN run "docker info" TO check swarm status
echo RUN "docker ps" TO check which containers are running
echo ----
echo "$(tput setaf 1) Check swarm token on https://discovery.hub.docker.com/v1/clusters/$SwarmTokenK $(tput sgr 0)"
echo ----

#Optionally close all non useful ports

#KILLS SWARM (Testing purposes cleanup)
docker-machine rm swarm-master
docker-machine rm SPAWN-CONSUL
docker-machine rm SPAWN-FigureITOUT




#Displays Public IP


