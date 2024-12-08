
provider "google" {
  credentials = "/home/manshidubey/manshi_prod/myproject-safle-297368874d36.json"
  project     = "myproject-safle"  
  region      = "us-central1"     
  zone        = "us-central1-a"   
}


resource "google_compute_instance" "safle_jenkins_vm" {
  name         = "safle-jenkins-vm"     
  machine_type = "e2-medium"             
  zone         = "us-central1-a"         

  
  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20241115" 
    }
  }

  
  network_interface {
    network = "default"  
    access_config {
     
    }
  }

  
  metadata_startup_script = <<-EOT
    #!/bin/bash
   
    apt-get update -y
    apt-get upgrade -y

    #  Docker 
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Git 
    apt-get install -y git

    # Jenkins 
   sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
     https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
     https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins

   
    systemctl start jenkins
    systemctl enable jenkins
    EOT
}

# Output of the external IP address
output "vm_external_ip" {
  value = google_compute_instance.safle_jenkins_vm.network_interface[0].access_config[0].nat_ip
}
