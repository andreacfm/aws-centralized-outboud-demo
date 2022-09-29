## aws-centralized-outboud-demo

### Before applying

* You must have 3 aws accounts ready to use (master, prod and dev)
* You will use credentials from the master account to run the terraform plan. Ensure that this profile may assume
a role in dev and prod account. For this demo you will assign Admin permissions to these roles (not recommended for production)
* The architecture will create the required VPC endpoints to start an ssm session with an ec2 instance deployed in dev and in prod account

### Architecture




### Test the deployment

The terraform apply will give you on output that looks like:

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








