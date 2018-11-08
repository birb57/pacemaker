$samplescript = <<SCRIPT
yum install yum-utils
yum-config-manager --enable extras
yum install redhat-upgrade-tool.noarch -y
echo "192.168.50.10 rhcs1.example.com" >> /etc/hosts
echo "192.168.50.11 rhcs2.example.com" >> /etc/hosts
#systemctl enable puppet
#systemctl start puppet
SCRIPT

Vagrant.configure(2) do |config|
  config.vm.box = "minimal/centos7"
  #config.vm.hostname = "myhost"
  #config.vm.network "private_network", ip: "192.168.50.10"
  #config.vm.synced_folder "src/", "/var/www/html"

  #config.vm.provision "shell", inline: $samplescript

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "2"
    vb.customize ["modifyvm", :id, "--usb", "off"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
  end

  config.vm.define :rhcs1 do |rhcs1|
    rhcs1.vm.hostname = "rhcs1.example.com"
    rhcs1.vm.network "private_network", ip: "192.168.50.10", auto_config: false
    config.vm.provision "shell", path: "build1.sh"
    rhcs1.vm.synced_folder "rhcs1/", "/usr/local/bin", create: true
    #srv.vm.network "forwarded_port", guest: 80, host: 8080
    #srv.vm.provision "shell", path: "server-provision"
  end

  config.vm.define :rhcs2 do |rhcs2|
    rhcs2.vm.hostname = "rhcs2"
    rhcs2.vm.network "private_network", ip: "192.168.50.11", auto_config: false
    config.vm.provision "shell", path: "build2.sh"
    rhcs2.vm.synced_folder "rhcs2/", "/usr/local/bin", create: true
    #srv.vm.network "forwarded_port", guest: 80, host: 8080
    #srv.vm.provision "shell", path: "server-provision"
  end

end

