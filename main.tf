terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "wp_network" {
  name = "wp_network"
}

resource "docker_volume" "db_data" {
  name = "db_data"

  lifecycle {
    prevent_destroy = true
  }
}


resource "docker_container" "mariadb" {
  image = "mariadb:latest"
  name  = "mariadb"
  restart = "always"

  env = [
    "MYSQL_DATABASE=${var.db_name}",
    "MYSQL_USER=${var.db_user}",
    "MYSQL_PASSWORD=${var.db_password}",
    "MYSQL_ROOT_PASSWORD=root_password"
  ]

  networks_advanced {
    name = docker_network.wp_network.name
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/mysql"
  }
}

resource "docker_container" "wordpress" {
  image = "wordpress:latest"
  name  = "wordpress"
  restart = "always"

  env = [
    "WORDPRESS_DB_HOST=mariadb:3306",
    "WORDPRESS_DB_NAME=${var.db_name}",
    "WORDPRESS_DB_USER=${var.db_user}",
    "WORDPRESS_DB_PASSWORD=${var.db_password}"
  ]

  networks_advanced {
    name = docker_network.wp_network.name
  }

  ports {
    internal = 80
    external = 8080
  }
}
