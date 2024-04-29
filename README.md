# Highly Available Application
A web application deployed on cloud with High Availability as focus.

## Table of Contents
- [HA App](#highly-available-application)
  - [Description](#description)

## Description
The components of the web application are deployed across two Availability Zones.
Internet access for public and private subnets via Internet and NAT Gateways.
Multi-AZ deployment for Amazon RDS Aurora across two subnets for data redundancy.
Amazon EFS cluster to enable data sharing between instances of application.
Load Balancer to distribute traffic and Auto-Scaling group to handle the demand fluctuation.
Infrastructure provisioned with Terraform to practice Infrastructure as Code standard.