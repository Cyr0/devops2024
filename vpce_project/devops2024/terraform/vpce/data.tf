# ami which is amazon linux 2023 , hvm type, x64
data "aws_ami" "amazon_linux" {
    most_recent = true

    filter {
        name = "name"
        values = ["al2023-ami-2023*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }

}