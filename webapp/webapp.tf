provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "userData" {
  template = "${file("userdata.tpl")}"
  vars = {
    username = "Jalil 4 da win"
  }
}

data "aws_vpc" "targetVPC" {
  filter = {
    name = "tag:ENV"
    values = ["training-tf"]
  }
}

data "aws_subnet_ids" "targetSubnetIds" {
  # availability_zone = "${var.region}*"
  vpc_id = "${data.aws_vpc.targetVPC.id}"
  filter = {
    name = "tag:ENV"
    values = ["training-tf"]
  }
}

resource "aws_security_group" "mySecurityGroup" {
  name        = "allow web and ssh"
  description = "Allow web and ssh"
  vpc_id      = "${data.aws_vpc.targetVPC.id}"
  tags = {
    Name = "mySecurityGroup"
    ENV  = "training-tf"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  user_data     = "${data.template_file.userData.rendered}"
  subnet_id = "${element(data.aws_subnet_ids.targetSubnetIds.ids, 0)}"
  vpc_security_group_ids = ["${aws_security_group.mySecurityGroup.id}"]
  associate_public_ip_address = true

  tags = {
    Name = "myVM"
    ENV  = "training-tf"
  }
}

