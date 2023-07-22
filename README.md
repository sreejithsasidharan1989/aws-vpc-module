## AWS VPC Module
---------
This custom module is developed to create VPC within the Region. The module also take care of subnetting the VPC based on the number of availability zone in the specified region. Two set of subnets are created for each availability zone, 1. Public & 2. Private subnets.
Below is a list of resources that will deployed by this module:
1. AWS VPC
2. AWS Internet Gateway
3. AWS Subnets
4. AWS Route Table
5. AWS Nat_Gateway & Elastic IP [ Based on run-time choice ]

Resources that will be added to private subnets will not be able to communicate with public network hence they are considered to be secure network. However, for resources that require public access, will be attached to a subnet that is connected to a nat-gateway.

#### prerequisite
```
Terraform AWS Provider >= 5.0.0
```
