This is a 3 tier architecture code created in JSON format, 

By provisioning this on AWS cloud our our 3-tier setup will be built:

The code will do following steps:

1. Creates a VPC with the CIDR block provided in the region you want.
2. Creates subnets for each layer.
3. Creates an IGW and NAT gateway.
4. Creates Route tables.
5. Creates a RDS instance.
6. Configures security group for Web layer.
7. EC2 instances for webservers.
8. Application load balancer.
