# Get AMI id here
data "aws_ami" "server_ami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "sc_node_id" {
  byte_length = 2
  count       = var.main_instance_count
}

resource "aws_key_pair" "sc_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "sc_main_instance" {
  count                  = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  vpc_security_group_ids = [aws_security_group.sc_sg.id]
  subnet_id              = aws_subnet.sc_public_subnet[count.index].id
  key_name               = aws_key_pair.sc_auth.id

  tags = {
    Name = "sc_main_instance-${random_id.sc_node_id[count.index].dec}"
  }

  # we will do the same trough ansible
  user_data = templatefile("/home/vboxuser/Desktop/project/Project_DEVOPS/ansible/userdata.tpl", { new_hostname = "sc-main-${random_id.sc_node_id[count.index].dec}" })

  root_block_device {
    volume_size = var.main_vol_size
  }

  provisioner "local-exec" {
    command = "printf '\n${self.public_ip}' >> aws_hosts "
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }
}


output "instance_ips" {
  value = { for i in aws_instance.sc_main_instance[*] : i.tags.Name => "${i.public_ip}:3000" }
}