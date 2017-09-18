#!/bin/bash

SWARM_MASTER_PUBLIC=$1
SWARM_MASTER_PRIVATE=$2
SWARM_WORKER=$3
HOST_TYPE=$4
SSH_TOKEN=$(ssh -i mentat.pem -o StrictHostKeyChecking=no ubuntu@$SWARM_MASTER_PUBLIC 'sudo docker swarm join-token -q worker')
HOSTNAME=$(ssh -i mentat.pem -o StrictHostKeyChecking=no ubuntu@$SWARM_WORKER 'hostname')

# There has been a race condition causing failure. Retry up to 5 times to get SSH token and Hostname to ensure connectivity
# This workound is inelegant and should be replaced with something more reliable, preferably using AWS CLI

n=0
until [ $n -ge 5 ]
do
   if [ -z $SSH_TOKEN ]
   then
     SSH_TOKEN=$(ssh -i mentat.pem -o StrictHostKeyChecking=no ubuntu@$SWARM_MASTER_PUBLIC 'sudo docker swarm join-token -q worker')
   else
     break
   fi
   n=$[$n+1]
   sleep 15
done


m=0
until [ $m -ge 5 ]
do
   if [ -z $HOSTNAME ]
   then
     HOSTNAME=$(ssh -i mentat.pem -o StrictHostKeyChecking=no ubuntu@$SWARM_WORKER 'hostname')
   else
     break
   fi
   m=$[$m+1]
   sleep 15
done

ssh -i mentat.pem -o StrictHostKeyChecking=no ubuntu@$SWARM_WORKER "sudo docker swarm join --token $SSH_TOKEN $SWARM_MASTER_PRIVATE:2377"
ssh -i mentat.pem -o StrictHostKeyChecking=no ubuntu@$SWARM_MASTER_PUBLIC "sudo docker node update --label-add type=$HOST_TYPE $HOSTNAME"
