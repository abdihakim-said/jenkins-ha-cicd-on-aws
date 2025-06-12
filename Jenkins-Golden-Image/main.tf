

provider "aws" {
  region = "us-east-1"
}

variable "efs_id" {
  description = "EFS File System ID"
  type        = string
}

data "aws_efs_file_system" "myefs" {
  file_system_id = var.efs_id
}

resource "null_resource" "script_file" {
  provisioner "local-exec" {
    command = "packer build -var efsid=${data.aws_efs_file_system.myefs.id} aws-ami.json"
  }
}
