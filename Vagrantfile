# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.define "ansible" do |ansible|
      ansible.vm.box = "jaca1805/debian12"
      ansible.vm.network "private_network", ip: "192.168.33.5"
      ansible.vm.synced_folder "config", "/home/vagrant/config"

      ansible.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = "2"
      end
  
      ansible.vm.provision "shell", path: "ansible.sh"
    end

  end
  