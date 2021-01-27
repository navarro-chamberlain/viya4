# Reference: https://github.com/terraform-providers/terraform-provider-aws

# Hack for assigning disk in a vm based on an index value. 
locals {
  device_name = [
    "/dev/sdb",
    "/dev/sdc",
    "/dev/sdd",
    "/dev/sde",
    "/dev/sdf",
    "/dev/sdg",
    "/dev/sdh",
    "/dev/sdi",
    "/dev/sdj",
    "/dev/sdk",
    "/dev/sdl",
    "/dev/sdm",
    "/dev/sdn",
    "/dev/sdo",
    "/dev/sdp",
    "/dev/sdq",
    "/dev/sdr",
    "/dev/sds",
    "/dev/sdt",
    "/dev/sdu",
    "/dev/sdv",
    "/dev/sdw",
    "/dev/sdx",
    "/dev/sdy",
    "/dev/sdz"
  ]
}

data "aws_ami" "centos" {
  owners      = ["aws-marketplace"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "admin" {
  key_name   = "${var.name}-admin"
  public_key = var.ssh_public_key
}

resource "aws_instance" "vm" {
  count         = var.create_vm ? 1 : 0
  ami           = data.aws_ami.centos.id
  instance_type = var.vm_type
  user_data     = (var.cloud_init != "" ? var.cloud_init : null)
  key_name      = aws_key_pair.admin.key_name

  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.create_public_ip

  root_block_device {
    volume_type           = var.os_disk_type
    volume_size           = var.os_disk_size
    delete_on_termination = var.os_disk_delete_on_termination
    iops                  = var.os_disk_iops
  }

  tags = merge(var.tags, map("Name", "${var.name}-vm"))

}

resource "aws_eip" "eip" {
  count = (var.create_vm && var.create_public_ip) ? 1 : 0
  vpc = true
  instance = aws_instance.vm.0.id
  tags = merge(var.tags, map("Name", "${var.name}-eip"))
}

resource "aws_volume_attachment" "data-volume-attachment" {
  count       = var.create_vm ? var.data_disk_count : 0
  device_name = element(local.device_name, count.index)
  instance_id = aws_instance.vm.0.id
  volume_id   = element(aws_ebs_volume.raid_disk.*.id, count.index)
}

resource "aws_ebs_volume" "raid_disk" {
  count             = var.create_vm ? var.data_disk_count : 0
  availability_zone = var.data_disk_availability_zone
  size              = var.data_disk_size
  type              = var.data_disk_type
  iops              = var.data_disk_iops
  tags              = merge(var.tags, map("Name", "${var.name}-vm"))
}
