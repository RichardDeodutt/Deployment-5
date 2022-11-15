resource "aws_instance" "jenkins" {
    ami = var.ami
    instance_type = var.itype
    associate_public_ip_address = true
    key_name = var.keyname

    security_groups = [
        var.secgroupname
    ]
    
    tags = {
        Name = "Jenkins Server"
    }
}

resource "null_resource" "executejenkins" {
    provisioner "remote-exec" {
        connection {
            host = aws_instance.jenkins.public_dns
            user = "ubuntu"
            private_key = file("files/id_rsa")
        }
        
        inline = [
            "echo 'Waiting for cloud-init to finish' && cloud-init status --wait"
        ]
    }
}

resource "aws_instance" "terraform" {
    ami = var.ami
    instance_type = var.itype
    associate_public_ip_address = true
    key_name = var.keyname

    security_groups = [
        var.secgroupname
    ]
    
    tags = {
        Name = "Jenkins Terraform Agent"
    }
}

resource "null_resource" "executeterraform" {
    provisioner "remote-exec" {
        connection {
            host = aws_instance.terraform.public_dns
            user = "ubuntu"
            private_key = file("files/id_rsa")
        }
        
        inline = [
            "echo 'Waiting for cloud-init to finish' && cloud-init status --wait"
        ]
    }
}

resource "aws_instance" "docker" {
    ami = var.ami
    instance_type = var.itype
    associate_public_ip_address = true
    key_name = var.keyname

    security_groups = [
        var.secgroupname
    ]
    
    tags = {
        Name = "Jenkins Docker Agent"
    }
}

resource "null_resource" "executedocker" {
    provisioner "remote-exec" {
        connection {
            host = aws_instance.docker.public_dns
            user = "ubuntu"
            private_key = file("files/id_rsa")
        }
        
        inline = [
            "echo 'Waiting for cloud-init to finish' && cloud-init status --wait"
        ]
    }
}