# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV['BOX_NAME'] || "ubuntu"
BOX_URI = ENV['BOX_URI'] || "http://files.vagrantup.com/precise64.box"
AWS_REGION = ENV['AWS_REGION'] || "us-east-1"
AWS_AMI    = ENV['AWS_AMI']    || "ami-d0f89fb9"

Vagrant::Config.run do |config|
  # Setup virtual machine box. This VM configuration code is always executed.
  config.vm.box = BOX_NAME
  config.vm.box_url = BOX_URI

  # Provision docker and new kernel if deployment was not done
  if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?
    # Add lxc-docker package
    pkg_cmd = "wget -q -O - https://get.docker.io/gpg | apt-key add -;" \
      "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list;" \
      "apt-get update -qq; apt-get install -q -y --force-yes lxc-docker; "

    # Add X.org Ubuntu backported 3.8 kernel
    pkg_cmd << "add-apt-repository -y ppa:ubuntu-x-swat/r-lts-backport; " \
      "apt-get update -qq; apt-get install -q -y linux-image-3.8.0-19-generic; "
    # Add guest additions if local vbox VM
    is_vbox = true
    ARGV.each do |arg| is_vbox &&= !arg.downcase.start_with?("--provider") end
    if is_vbox
      pkg_cmd << "apt-get install -q -y linux-headers-3.8.0-19-generic dkms; " \
        "echo 'Downloading VBox Guest Additions...'; " \
        "wget -q http://dlc.sun.com.edgesuite.net/virtualbox/4.2.12/VBoxGuestAdditions_4.2.12.iso; "
      # Prepare the VM to add guest additions after reboot
      pkg_cmd << "echo -e 'mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.2.12.iso /mnt\n" \
        "echo yes | /mnt/VBoxLinuxAdditions.run\numount /mnt\n" \
          "rm /root/guest_additions.sh; ' > /root/guest_additions.sh; " \
        "chmod 700 /root/guest_additions.sh; " \
        "sed -i -E 's#^exit 0#[ -x /root/guest_additions.sh ] \\&\\& /root/guest_additions.sh#' /etc/rc.local; " \
        "echo 'Installation of VBox Guest Additions is proceeding in the background.'; " \
        "echo '\"vagrant reload\" can be used in about 2 minutes to activate the new guest additions.'; "
    end
    # Activate new kernel
    pkg_cmd << "shutdown -r +1; "
    config.vm.provision :shell, :inline => pkg_cmd
  end
end


# Providers were added on Vagrant >= 1.1.0
Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws.keypair_name = ENV["AWS_KEYPAIR_NAME"]
    override.ssh.private_key_path = ENV["AWS_SSH_PRIVKEY"]
    override.ssh.username = "ubuntu"
    aws.region = AWS_REGION
    aws.ami    = AWS_AMI
    aws.instance_type = "t1.micro"
  end

  config.vm.provider :rackspace do |rs|
    config.ssh.private_key_path = ENV["RS_PRIVATE_KEY"]
    rs.username = ENV["RS_USERNAME"]
    rs.api_key  = ENV["RS_API_KEY"]
    rs.public_key_path = ENV["RS_PUBLIC_KEY"]
    rs.flavor   = /512MB/
    rs.image    = /Ubuntu/
  end

  config.vm.provider :virtualbox do |vb|
    config.vm.box = BOX_NAME
    config.vm.box_url = BOX_URI

    config.vm.network "private_network", ip: "192.168.50.4"
    
    if not Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?
      config.vm.provision :shell, :inline => 'sudo apt-get install nginx -y'
      config.vm.provision :shell, :inline => 'sudo adduser www-data docker'

      # sync dem folders over!
      config.vm.synced_folder "./nginx", "/etc/nginx/sites-enabled", nfs: true
      config.vm.synced_folder "./ssl", "/etc/nginx/certs", nfs: true
      config.vm.synced_folder "./trusted", "/home/vagrant/trusted", nfs: true
      config.vm.synced_folder "./trusted", "/home/vagrant/untrusted", nfs: true

      # fianlly, let us restar nignx, for great good!
      config.vm.provision :shell, :inline => 'sudo service nginx restart'

    end
  end
end
