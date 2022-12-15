

#----------------------------------------------------------
# ACS730 - Mid Term Exam
#
#
#----------------------------------------------------------

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# # Data source for availability zones in us-east-1
# data "aws_availability_zones" "available" {
#   state = "available"
# }


# Reference subnet provisioned by 01-Networking 
resource "aws_instance" "my_amazon" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2x.micro"
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = aws_subnet.public_subnet_2.id
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install_httpd.sh")

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-vm"
    }
  )
}


# Attach EBS volume
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.web_ebs.id
  instance_id = aws_instance.my_amazon.id
}



# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = "midterm.pub"
  public_key = file("midterm.pub")
}

# Create another EBS volume
resource "aws_ebs_volume" "web_ebs" {
  availability_zone = data.aws_availability_zones.available.names[1]
  size              = 40
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-vm"
    }
  )
}



