aws - terraform project - 12-02-2024
====================================
# vpc - cidr = 10.12.0.0/16
# igw = attach to vpc
# crate elastic ip
# ngw = attach to vpc?
        attach elastic ip

# iam roles from ec2 to efs
# iam roles from ec2 to s3

# security-group-public =
 * outbound = 0.0.0.0/0 any port
 * inbound = my_ip/32 port 22
 # public-route-table =
   * 10.12.0.0/16 = local
   * 0.0.0.0 = igw

# security-group-private =
 * outbound = 0.0.0.0/0 any port
 * inbound = 10.12.0.0/16 port 22
 # private-route-table =
   * 10.12.0.0/16 = local

# subnet-public = 10.12.0.0/17
 # subnet route table assiation public-route-table

# subnet-private = 10.12.128.0/17
 # default route table

# storage
# create efs for mounting
# create s3 and upload key and index.html to s3


# public-ec2 instance - subnet public, security group public 
# private ec2 instance - subnet private , security group private


# public-ec2 instance - user-data

# mount efs to public-ec2
download ssh key and index.html from s3 to efs share
chmod ~/.ssh/test.pem
install wget curl
 
rsync index.html from public ec2 to private ec2
 # on private ec2 install 
  # minikube => jenkins

# from public wget / curl to private ec2 on jenkins port > log
# rsync log from ec2 private to ec2 public efs share
# upload log to s3