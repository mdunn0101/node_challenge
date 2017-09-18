# Mongoose Demo Deployment

This is the work I have put together to do a mock deployment of the Node Express Mongo Demo application.

## Requirements

A Jenkins 2 server with Docker and Terraform installed - This has been targeted toward my pre-existing Jenkins setup and AWS account.

## Goals

The Node application, MongoDB and Nginx have been containerized and will be deployed into a Docker swarm.
Mongo is only accessible by web application containers, and the web containers are running on 3000 with all requests proxied in from nginx via port 80.
A publicly accessible URL is created upon deployment of the infrastructure at mongoose-${ENVIRONMENT}.azabu-juban.com (My personal test domain).
All S3 resources are created via a Jenkins job.

## Jenkins jobs

### deploy-infrastructure

Automates the deployment of all resources defined in terraform, including EC2 instances that bootstraps a Docker Swarm cluster.

### docker-build

A generic job that builds all the docker containers and pushes them to my registry.

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

Creates groups for each of the EC2 instances. Ensures that only nginx is world visible and can redirect traffic to web instances, mongo is only accessible by application containers, all instances can connect via swarm, and opens SSH to the instances from Jenkins.

### join_swarm.sh

Bootstraps the worker instances to the Swarm master. Used as a workaround for terraform's remote execution due to SSH problems.

## Docker images

### Dockerfile-app

The primary web application container.

### Dockerfile-mongo

An inherit Dockerfile that was not modified.

### Dockerfile-nginx

Another inherit container that has the nginx proxy configuration added to it.

## Areas of improvement

There are a number of pieces that can be greatly improved with further development time

### S3 bucket issue

This is the first time I have used Docker secrets, and though I am successfully mounting the S3 credentials, I am still having difficulty getting the keys into the application container's environment correctly. Thus, the S3 image repository isn't working.

### SSL

SSL is not enabled in the NGINX container.

### Error handling in Jenkins jobs

Some elements of the Jenkins jobs are brittle, such as the credential update job.

### Terraform state handling

Currently Terraform state files are being stashed in a folder on the Jenkins master. I would prefer to use Consul as a backend for storage.

### Environment definition

All of the environment variables in the Node application are the same, as they are connecting over a Dockerized network with identical configurations. However I would be more comfortable being able to define the environment via a variable (related to the S3 problem)
