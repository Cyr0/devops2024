# storage
################################################
# create efs-fs mounting target and access point
################################################

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
###############################################
# create s3 (force destory flag)
###############################################
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "${var.project_name}-${random_string.random_str.result}"
    force_destroy = true
    depends_on = [ random_string.random_str ]
}

# create random string for s3 bucket name
resource "random_string" "random_str" {
    length = 15
    special = false
    upper = false
}
