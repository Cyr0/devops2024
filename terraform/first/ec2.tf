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
