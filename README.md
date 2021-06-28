# Packer R-Studio Workbench AWS AMI

This project includes scripts to build an R-Studio Workbench AMI for AWS.

What's in:
 * Packer HCL config for building the image on AWS,
 * Ansible roles for provisioning essentials, R, R-Studio Workbench,
 * Vagrant config for building and testing the image build process locally.

## Requirements

You'll require the following tools installed and in your path:
 * packer
 * ansible
 * awscli
 * aws-vault

## Building the image

 1. Make sure all the required software (listed above) is installed,
 1. Load your AWS credentials into your environment.
 1. Run `packer`:
```
aws-vault exec appsilon-infra-sso -- packer build ami.pkr.hcl
```
