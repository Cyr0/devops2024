#terraform aws requierment
# on providers.tf

# aws terraform provider
# on providers.tf

# ec2 ami filtering
# on data.tf






# public-ec2 instance - subnet public, security group public
# download ssh key 
# chmod 400 ~/.ssh/test.pem
# install wget curl

resource "aws_instance" "ec2_public" {
    ami                    = data.aws_ami.amazon_linux.id
    instance_type          = "${var.ec2_instance_type}"
    subnet_id              = aws_subnet.subnet_public.id
    vpc_security_group_ids = [aws_security_group.public_security_group.id]
    #key_name               = "${var.private_key_name}"
    key_name               = aws_key_pair.ssh_key.key_name

    iam_instance_profile   = aws_iam_instance_profile.ec2_storage_full_access.name
    depends_on             = [ aws_iam_role.ec2_storage_role, aws_instance.ec2_private, 
                               tls_private_key.rsa, aws_key_pair.ssh_key, 
                               local_file.ssh_openssh_private_key ] 
                               # null_resource.install_putty, null_resource.pem2ppk  ]

    tags = {
      Name = "${var.project_name}-ec2_public"
    }
}

# private ec2 instance - subnet private , security group private

resource "aws_instance" "ec2_private" {
    ami                    = data.aws_ami.amazon_linux.id
    instance_type          = "${var.ec2_instance_type}"
    subnet_id              = aws_subnet.subnet_private.id
    vpc_security_group_ids = [aws_security_group.private_security_group.id]
    #key_name               = "${var.private_key_name}"
    key_name               = aws_key_pair.ssh_key.key_name
    iam_instance_profile   = aws_iam_instance_profile.ec2_storage_full_access.name
    # create file on efs mount and on local tmp directory and upload thoes file to s3
    # update ec2 instance, 
    # install efs-helper 
    # install pip3 and botocore cryptography as efs help dependency
    # for using efs mount
    user_data              = <<-EOF
                                #!/bin/bash
                                dnf update -y
                                CURRENT_DATE=$(date "+%d-%m-%Y-%H-%M")
                                export BUCKET_NAME="${aws_s3_bucket.s3_bucket.bucket}"
                                export OBJECT_KEY='files'
                                export EFS_DIR=/efs
                                export EFS_FILE=efs.test
                                export LOG_DIR=/tmp
                                export LOG_FILE=efs.log
                                sudo mkdir $EFS_DIR/
                                sudo dnf install -y amazon-efs-utils python3-pip
                                sudo pip3 install botocore cryptography
                                pip3 install botocore cryptography
                                echo '${aws_efs_file_system.efs.id}:/ $EFS_DIR efs defaults,_netdev,nofail 0 0' >> /etc/fstab
                                mount -a
                                sudo echo $CURRENT_DATE > $EFS_DIR/$EFS_FILE
                                ls -lha $EFS_DIR/ > $LOG_DIR/$LOG_FILE
                                aws s3 cp $EFS_DIR/$EFS_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$EFS_FILE 
                                aws s3 cp $LOG_DIR/$LOG_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$LOG_FILE
                                echo "aws s3 cp $EFS_DIR/$EFS_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$EFS_FILE" >> /tmp/test.log
                                echo "aws s3 cp $LOG_DIR/$LOG_FILE s3://$BUCKET_NAME/$OBJECT_KEY/$LOG_FILE" >> /tmp/test.log
                                EOF
    depends_on              = [ aws_iam_role.ec2_storage_role ]
        tags                = {
                                Name = "${var.project_name}-ec2_private"
        }
}


# storage
# create efs-fs mounting target and access point

resource "aws_efs_file_system" "efs" {
    creation_token = "${var.project_name}-efs"
    tags = {
        Name = "${var.project_name}-efs"
    }  
}
resource "aws_efs_mount_target" "efs_mount" {
    file_system_id = aws_efs_file_system.efs.id
    subnet_id = aws_subnet.subnet_private.id
    security_groups = [ aws_security_group.private_efs_security_group.id ]
    depends_on = [ aws_efs_file_system.efs ]
}

resource "aws_efs_access_point" "efs_access_point" {
    file_system_id = aws_efs_file_system.efs.id
    depends_on = [ aws_efs_file_system.efs ]
}
  
# create random string for s3 bucket name
resource "random_string" "random_str" {
    length = 15
    special = false
    upper = false
}

# create s3 and upload key and index.html to s3
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "${var.project_name}-${random_string.random_str.result}"
    force_destroy = true
}

##############################
# TODO:
##############################
# Create EKS + Dependencies
##############################
##############################
# Use tfvars
##############################
##############################
# Use Secrets
##############################
##############################
# Change Structure to Modules
##############################
##############################
# Store Tfstate in dynamodb 
##############################

####################################################################################
# Create Zabbix Server and Zabbix Agent + Update Zabbix Server regarding new agent.
####################################################################################

####################################################################################
# Learn About IIS
####################################################################################