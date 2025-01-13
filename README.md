This repo is used to install LEMP stack using Docker for development (not secure enough for production).
### Install
Clone the repo and install
```
git clone git@github.com:lshung/lemp-dev.git
cd lemp-dev
bash install.sh
```
Start the container if it does not automatically start or after rebooting your system
```
docker start lemp-ctn
```
### How to use
- URL: http://localhost
- Phpmyadmin URL: http://localhost/phpmyadmin
- MYSQL root username: root
- MYSQL root password: root
### Manage virtual hosts
You can list, add, or delete your virtual hosts using this command
```
bash vhost.sh
```
Note: To add or delete a virtual host, you need sudo privileges to edit /etc/hosts.

For example, if you create a virtual host example.com, your project's source code will be located at ./www/example.com.

If you encounter permission issues with your source code, run this command to grant permissions
```
sudo chown -R 33:33 ./www
```
### Uninstall
Go to the lemp-dev directory and run
```
bash uninstall.sh
```
