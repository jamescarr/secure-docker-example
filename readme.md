# Secure Docker Example

This example uses the same vagrant setup found in docker to setup a
virtual machine with docker running on it. This also configures nginx to
run with client-side ssl validation and defines the docker unix socket
as an upstream. 

Running this can be tricky due to the complexity of setting docker up
right the first time. The very first time you run vagrant up Vbox Guest
extensions and other things will be installed. Wait 2 minutes before
running `vagrant reload`. You may also need to run `vagrant provision`
afterwards as well to install and configure nginx. 

Have fun!


