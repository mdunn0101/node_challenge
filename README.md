# Mongoose Demo Deployment

This is the work I have put together to do a mock deployment of the Node Express Mongo Demo application.

## Getting started

Log into the azabu-juban Jenkins instance and run the following jobs:

mongoose/docker-build-image (optional) - Build the containers used in the deployment

mongoose/deploy-aws-infrastructure - *Get the IP address for the Nginx instance* (This is also the Docker Swarm master)

mongoose/deploy-secrets - Write docker secrets to the Swarm master

mongoose/deploy-app - Deploy the application to http://mongoose-production.azabu-juban.com

Wait a minute or so until the application is deployed and visit the site for verification

## Jenkins Requirements

Jenkins 2 server with Terraform and Docker CE installed

AWS keypair with EC2, S3 and Route 53 permissions saved as secret text file

EC2 instance keypair saved as secret text file

## Goals

Node application, MongoDB and Nginx have been containerized and will be deployed into a Docker swarm.

MongoDB is only accessible by web application containers, and the web containers are running on tcp/3000 with all requests proxied in from nginx via port 80.

A publicly accessible URL is created upon deployment of the infrastructure at mongoose-${ENVIRONMENT}.azabu-juban.com (My personal test domain).

All S3 resources are created via a Jenkins job.

## Jenkins jobs

### deploy-infrastructure

Automates the deployment of all resources defined in terraform, including EC2 instances that bootstraps a Docker Swarm cluster.

### docker-build

A generic job that builds all the docker containers and pushes them to my registry in AWS.

### deploy-secrets

Takes secrets stored on the Jenkins server and applies them to the Swarm cluster.

### deploy-application

Copies the docker-compose.yml file to the cluster master and builds the stack.

## Terraform resources

### EC2

Creates 3 EC2 instances from an AMI that has Docker pre-installed. A swarm is launched on these instances, and they are given tags for the placement of the proper containers.

### route53

Creates a world-accessible DNS entry at mongoose-${ENVIRONMENT}.azabu-juban.com for application verification.

### s3

Creates the bucket required by the application for image storage.

### security groups

Creates security groups for each of the EC2 instances.

**Ensures:**
+ Nginx is world visible and can redirect traffic to web containers
+ Mongo is only accessible by application containers
+ All instances can connect via swarm
+ Opens SSH to the instances from Jenkins

### join_swarm.sh

Script used by Terraform to bootstrap worker instances to the Swarm master. Used as a workaround for terraform's remote execution due to SSH problems.

## Docker images

### Dockerfile-app

The primary web application container.

### Dockerfile-mongo

An inherit Dockerfile that was not modified.

### Dockerfile-nginx

Another inherit container that has the nginx proxy configuration added to it.
