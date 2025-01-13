#!/bin/bash

CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/components/nginx/conf.d"

# Function to list all virtual hosts
_list_vhosts() {
  # List .conf files excluding default.conf
  find "$CONFIG_DIR" -type f -name "*.conf" ! -name "default.conf" -printf "%f\n" | sed 's/\.conf$//'
}

# Function to add a new virtual host configuration file
_add_vhost() {
  local vhost_name=$1
  local config_file="$CONFIG_DIR/$vhost_name.conf"
  local project_dir="$(dirname "${BASH_SOURCE[0]}")/www/$1"

  # Create the new .conf file
  cat <<EOL >"$config_file"
server {
  listen 80;
  server_name $1;

  root /var/www/html/$1;
  index index.php index.html index.htm;

  location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
  }

  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }

  client_max_body_size 50M;
}
EOL

  # Update /etc/hosts
  sudo sh -c "echo 127.0.0.1 $vhost_name >> /etc/hosts"

  # Create source code directory
  mkdir -p "$project_dir"
  echo "Create vhost $1 successfully."
  echo "Nginx config file: $config_file"
  echo "Project directory: $project_dir"
  _restart_docker_container
}

# Function to delete a vhost
_delete_vhost() {
  local vhost_name=$1
  local config_file="$CONFIG_DIR/$vhost_name.conf"
  rm -f $config_file

  # Update /etc/hosts
  sudo sed -i "/127.0.0.1 $vhost_name/d" /etc/hosts
  echo "Delete vhost $1 successfully."
  echo "Project source code and data are not removed."
  _restart_docker_container
}

# Function to restart Docker container
_restart_docker_container() {
  if docker restart lemp-ctn >/dev/null; then
    echo "Restart Docker container lemp-ctn successfully."
  else
    echo "Cannot restart Docker container lemp-ctn:" 1>&2
  fi
}

# Menu to select options using select
PS3="Enter your choice: "
options=("List vhosts" "Add vhost" "Delete vhost" "Exit")
select choice in "${options[@]}"; do
  case $REPLY in
  1)
    _list_vhosts
    ;;
  2)
    read -p "Enter the vhost name to add: " vhost_name
    _add_vhost "$vhost_name"
    break
    ;;
  3)
    read -p "Enter the vhost name to delete: " vhost_name
    _delete_vhost "$vhost_name"
    break
    ;;
  4)
    break
    ;;
  *)
    echo "Invalid choice, please try again."
    ;;
  esac
done
