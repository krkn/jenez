#
# Vagrant template
#
# @author   Akarun for KRKN <akarun@krkn.be>
# @since    August 2013
#
#  ============================================================================

# Configuration
name = 'project_name'   # VM name
host = 'project.local'  # Web access
ip = '10.0.0.6'         # IP for private network

#  ----------------------------------------------------------------------------
Vagrant.configure("2") do |config|
    config.vm.box = "wheezy64"
    config.vm.box_url = "http://vagrant.krkn.be/debian-wheezy64.box"

    config.vm.hostname = host
    config.vm.network :private_network, ip: ip
    #config.vm.network :public_network, :bridge => "en0: Ethernet"
    config.vm.network :forwarded_port, guest: 27017, host: 27017
    config.vm.network :forwarded_port, guest: 6379, host: 6379

    # Vagrant Provisionning
    if File.exists?('.vagrant/vm.provision.sh') then
        config.vm.provision :shell, :path => ".vagrant/vm.provision.sh", :args => [name, host], :keep_color => true
    end

    # Configure Virtualbox VM
    config.vm.provider "virtualbox" do |v|
        v.name = name.sub(/^(\w)/) {|s| s.capitalize}
        # v.gui = true
    end
end
