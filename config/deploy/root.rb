## This stage will run the server as root user
# sudo access is required
# You can use the following command to add the user to the sudoers file considering the user is ubuntu
# echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ubuntu

set :systemctl_user, :system