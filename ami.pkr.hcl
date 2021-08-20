variable "aws_region" {
  description = "AWS Region where the AMI will be created"
  type        = string
  default     = "eu-west-1"
}

variable "r_version" {
  description = "Version of R to install on AMI"
  type        = string
  default     = "40"
}

variable "rstudio_version" {
  description = "Version of RStudio Server to install on AMI"
  type        = string
  default     = "1.4.1717"
}

source "amazon-ebs" "rstudio-server" {
  ami_description = "RStudioServer v${var.rstudio_version} with R v${var.r_version}"
  ami_name        = "RStudioServer-${var.rstudio_version}-R-${var.r_version}-${formatdate("DDMMMYYYY-hhmmssZZZ", timestamp())}"
  ami_regions     = [var.aws_region]
  ena_support     = "true"
  encrypt_boot    = "true"
  instance_type   = "t3.medium"
  region          = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # canonical
  }
  ssh_username = "ubuntu"


  run_volume_tags = {
    Name = "rstudio-server-ami"
  }

  run_tags = {
    Name = "rstudio-server-ami"
  }
  tags = {
    RStudioServerVersion = var.rstudio_version
    RVersion             = var.r_version
    Name                 = "rstudio-server-ami"
  }
}

build {
  sources = ["source.amazon-ebs.rstudio-server"]

  provisioner "shell" {
    inline = [
      "sleep 10",
      "sudo apt update -y",
      "sudo apt install python3 python3-pip -y",
      "sudo pip3 install -q ansible",
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "./playbook.yml"
    role_paths = [
      "./roles/base",
      "./roles/r",
      "./roles/rstudio-workbench"
    ]
    extra_arguments = [
      "--extra-vars",
      "\"r_version=${var.r_version} rstudio_version=${var.rstudio_version}\"",
    ]
  }

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}
