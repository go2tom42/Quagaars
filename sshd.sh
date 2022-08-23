sudo rm -f /etc/ssh/sshd_not_to_be_run
sudo systemctl enable ssh
sudo systemctl start ssh
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/PermitRootLogin no/PermitRootLogin yes/" /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart
echo 'root:bitnami' | sudo chpasswd
sudo reboot 0
