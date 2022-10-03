## aws-centralized-outboud-demo

### Before applying

* You must have 3 aws accounts ready to use (master, prod and dev)
* You will use credentials for the master account to run the terraform plan. Ensure that this profile may assume
a role in dev and prod account. For this demo you will assign Admin permissions to these roles (not recommended for production)

### Architecture

![outboud](https://user-images.githubusercontent.com/47330/193579825-c3b9d450-e8c6-45ee-a7e9-5b09e813b617.jpg)

* In this example we will create the required VPC endpoints to start a ssm session with an ec2 instances deployed in dev and prod private subnets

### Deploy

Create a terraform.tfvars with the required variables:

```shell
prod_iam_role_arn = "Role arn in prod account that can be assumed by the master account executing the terraform plan"
dev_iam_role_arn  = "Role arn in dev account that can be assumed by the master account executing the terraform plan"
aws_region        = "us-east-1"
```

Plan and apply terraform. You will give you on output that looks like the following:

```shell
dev_instance_id = "i-0498bc740f2fc2cee"
dev_instance_ip = "172.18.2.209"
prod_instance_id = "i-0fb9005f0c50a6a4e"
prod_instance_ip = "172.19.2.209"
```

#### Test the vpc endpoints

Open a shell that uses the dev account credentials.
```shell
aws ssm start-session --target [dev_instance_id]

## When connected
ping [prod_instance_ip]
```
Do the same logging into the prod instance and ping the dev ip

Both tha connection to the SSM endpoint that dev<->prod are flowing through the outboud account.








