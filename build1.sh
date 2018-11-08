#!/bin/bash

yum-config-manager --enable extras


#cat < /etc/yum.repos.d/centos.repo
#[centos-7-base]
#name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
##baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
#enabled=1
#EOF

# Next we use yum to install pacemaker and some other necessary packages we will need:

yum install -y pacemaker pcs resource-agents

# Create the Cluster
# The supported stack on RHEL7 is based on Corosync 2, so thats what Pacemaker uses too.

# First make sure that pcs daemon is running on every node:


systemctl start pcsd.service
systemctl enable pcsd.service

# Then we set up the authentication needed for pcs.


echo CHANGEME | passwd --stdin hacluster
pcs cluster auth rhcs1.example.com rhcs2.example.com -u hacluster -p CHANGEME --force

#We now create a cluster and populate it with some nodes. Note that the name cannot exceed 15 characters (we'll use 'pacemaker1').


pcs cluster setup --force --name pacemaker1 rhcs1.example.com rhcs2.example.com

# Start the Cluster

pcs cluster start --all

#Set Cluster Options
#With so many devices and possible topologies, it is nearly impossible to include Fencing in a document like this. For now we will disable it.


pcs property set stonith-enabled=false

#One of the most common ways to deploy Pacemaker is in a 2-node configuration. However quorum as a concept makes no sense in this scenario (because you only have it when more than half the nodes are available), so we'll disable it too.


pcs property set no-quorum-policy=ignore

#For demonstration purposes, we will force the cluster to move services after a single failure:

pcs resource defaults migration-threshold=1

#Add a Resource
#Lets add a cluster service, we'll choose one doesn't require any configuration and works everywhere to make things easy. Here's the command:

pcs resource create my_first_svc Dummy op monitor interval=120s

#"my_first_svc" is the name the service will be known as.
#"ocf:pacemaker:Dummy" tells Pacemaker which script to use (Dummy - an agent that's useful as a template and for guides like this one), which namespace it is in (pacemaker) and what standard it conforms to (OCF).
#"op monitor interval=120s" tells Pacemaker to check the health of this service every 2 minutes by calling the agent's monitor action.
#You should now be able to see the service running using:

pcs status

#or
#[ONE] # crm_mon -1

#Simulate a Service Failure
#We can simulate an error by telling the service to stop directly (without telling the cluster):

crm_resource --resource my_first_svc --force-stop

#If you now run crm_mon in interactive mode (the default), you should see (within the monitor interval of 2 minutes) the cluster notice that my_first_svc failed and move it to another node.
#:x

