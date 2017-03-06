# Run using Docker

[![Docker Automated buil](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/cbioportal/cbioportal/) [![Docker Pulls](https://img.shields.io/docker/pulls/cbioportal/cbioportal.svg)](https://hub.docker.com/r/cbioportal/cbioportal/) [![Docker Stars](https://img.shields.io/docker/stars/cbioportal/cbioportal.svg)](https://hub.docker.com/r/cbioportal/cbioportal/)

Docker provides a way to run applications securely isolated in a container, packaged with all its dependencies and libraries.
To learn more on Docker, kindly refer here: [What is Docker?](https://www.docker.com/what-docker).

## Supported tags and respective `Dockerfile` links

-       [`latest` (*latest/Dockerfile*)](https://github.com/cBioPortal/cbioportal/blob/latest/Dockerfile)
-       [`1.4.3` (*1.4.3/Dockerfile*)](https://github.com/cBioPortal/cbioportal/blob/1.4.3/Dockerfile)

## Prerequisites

- 1. Install Docker
- 2. Download Seed DB
- 3. Prepare Configuration Files

### 1. Install Docker

First, make sure that you have the latest version of Docker installed on your machine. [Get latest version](https://www.docker.com/products/overview#/install_the_platform)

### 2. Download Seed DB

The latest cBioPortal Seed files are available from the [cbioportal datahub](https://github.com/cBioPortal/datahub/tree/master/seedDB).    
You can download these files by using the links below:

- **Schema 1.3.0**: [SQL file with create table statements for portal release 1.3.1](https://raw.githubusercontent.com/cBioPortal/cbioportal/v1.3.1/core/src/main/resources/db/cgds.sql) 
- **Seed data, part1**: [cbioportal-seed SQL (.gz) file - part1 (no pdb_ tables)](https://github.com/cbioportal/datahub/raw/b69c86803c40d543080bf31a645721d06c82d08d/seedDB/seed-cbioportal_no-pdb_hg19.sql.gz)
- **Seed data, part2 (optional)** [cbioportal-seed SQL (.gz) file - part2 (only pdb_ tables)](https://github.com/cbioportal/datahub/raw/b69c86803c40d543080bf31a645721d06c82d08d/seedDB/seed-cbioportal_only-pdb.sql.gz)

### 3. Prepare Configuration Files

You will need the following configuration files.

- [portal.properties](Pre-Build-Steps.md#prepare-property-files)
- [log4j.properties](Pre-Build-Steps.md#prepare-the-log4jproperties-file)
- [settings.xml](Pre-Build-Steps.md#create-a-maven-settings-file)
- [context.xml](Deploying.md#set-up-the-database-connection-pool)
- gene_sets.txt (optional) | Pending
- Logos (optional) | Pending

You can download some example files from here:

## Install cBioPortal using docker in 5'

### Create Docker Network

```bash
docker network create "cbioportal-net"
```

### Run MySQL Docker container

```bash
docker run -d --name "{CONTAINER-NAME}" \
--restart=always \
--net="{DOCKER-NETWORK-NAME}" \
-p "{PREFERRED-EXTERNAL-PORT}":3306 \
-e MYSQL_ROOT_PASSWORD="{MYSQL-ROOT-PASSWORD}" \
-v "{/PATH/TO/MYSQL/DATA}":/var/lib/mysql \
-v "{/PATH/TO/SEED/DATABASE}"/cgds.sql:/docker-entrypoint-initdb.d/cgds.sql:ro \
-v "{/PATH/TO/SEED/DATABASE}"/seed-cbioportal_no-pdb_hg19.sql.gz:/docker-entrypoint-initdb.d/seed_part1.sql.gz:ro \
-v "{/PATH/TO/SEED/DATABASE}"/seed-cbioportal_only-pdb.sql.gz:/docker-entrypoint-initdb.d/seed_part2.sql.gz:ro \
mysql
```

### Run DB Migrations

```bash
docker run --rm -it --net cbioportal-net \
cbioportal/cbioportal \
migrate_db.py -p /cbioportal/src/main/resources/portal.properties -s /cbioportal/core/src/main/resources/db/migration.sql
```

### Run cBioPortal Container

```bash
docker run -d --name "{CONTAINER-NAME}" \
--restart=always \
--net="{DOCKER-NETWORK-NAME}" \
-p "{PREFERRED-EXTERNAL-PORT}":8080 \
-v "{/PATH/TO/portal.properties}":/cbioportal/src/main/resources/portal.properties:ro \
-v "{/PATH/TO/log4j.properties}":/cbioportal/src/main/resources/log4j.properties:ro \
-v "{/PATH/TO/settings.xml}":/root/.m2/settings.xml:ro \
-v "{/PATH/TO/context.xml}":/usr/local/tomcat/conf/context.xml:ro \
-v "{/PATH/TO/CBIOPORTAL-LOGS}":/cbioportal_logs/ \
-v "{/PATH/TO/TOMCAT-LOGS}":/usr/local/tomcat/logs/ \
-v "{/PATH/TO/STUDIES}":/cbioportal_studies/:ro \
cbioportal/cbioportal:{TAG}
```

## cBioPortal Setup

## 1. Database Setup

As of this writing, the cBioPortal software runs properly on MySQL version 5.0.x. The software can be found and downloaded from the [MySQL website](https://www.mysql.com).

There are two options to set up the cBioPortal Database:    
1. Run MySQL on the host.    
2. Run MySQL as a Docker container.    

### 1.1 Run MySQL on the host

To install MySQL 5.7, kindly follow the vendor’s official detailed installation guide, available [here](http://dev.mysql.com/doc/refman/5.7/en/installing.html).

### 1.2 Run MySQL as a docker container

#### 1.2.1 Create a docker network

Because MySQL and cBioPortal are running on separate containers, docker needs to know how to link them. Using Docker's legacy `--link` flag tends to be fragile since it will break if the MySQL container is restarted. 

To get around this, we can use the newer `Docker networks` feature by typing the following command:

```bash
docker network create "{DOCKER-NETWORK-NAME}"
```

Where:
- **{DOCKER-NETWORK-NAME}** is the name of the network that cBioPortal and the cBioPortal DB are going to be accessible. _i.e If the network is called **"cbioportal-net"** the command should be:_

**Example**

```bash
docker network create "cbioportal-net"
```

Running the above command will create a docker network called **"cbioportal-net"**.

- Learn more on [docker container networking](https://docs.docker.com/engine/userguide/networking/).
- Learn more on [docker network create](https://docs.docker.com/engine/reference/commandline/network_create/).

#### 1.2.2 Launch MySQL docker container

In a docker terminal type the following command:

```bash
docker run -d --name "{CONTAINER-NAME}" \
--restart=always \
--net="{DOCKER-NETWORK-NAME}" \
-p "{PREFERRED-EXTERNAL-PORT}":3306 \
-e MYSQL_ROOT_PASSWORD="{MYSQL-ROOT-PASSWORD}" \
-v "{/PATH/TO/MYSQL/DATA}":/var/lib/mysql \
mysql
```

Where:    
- **{CONTAINER-NAME}**: The name of your container instance _i.e **cbio-DB**_.
- **{DOCKER-NETWORK-NAME}**: The name of your network _i.e **cbioportal-net**_.
- **{PREFERRED-EXTERNAL-PORT}**: The port that the container internal port will be mapped to _i.e **8306**_.
- **{MYSQL-ROOT-PASSWORD}**: The root password for the MySQL installation. For password restrictions please read carefully this [link](http://dev.mysql.com/doc/refman/5.7/en/user-names.html).
- **{/PATH/TO/MYSQL/DATA}**: The MySQL path were all MySQL Data are stored.

Running the above command will create a MySQL docker container and will automatically import the Seed Database.

#### MySQL Logs monitoring in Docker

MySQL logs can easily be monitored by executing the following command on a terminal with docker.

```bash
docker logs "{CONTAINER-NAME}"
```

Where:    
- **{CONTAINER-NAME}**: The name of your container instance _i.e **cbio-DB**_.

Learn more on [docker logs](https://docs.docker.com/engine/reference/commandline/logs/).

#### Useful Resources

[MySQL Docker Hub](https://hub.docker.com/_/mysql/)    
[MySQL Docker Github](https://github.com/docker-library/docs/tree/master/mysql)

### 1.3 Create the cBioPortal MySQL Databases and User

You must create a `cbioportal` database and a `cgds_test` database within MySQL, and a user account with rights to access both databases.  This is done via the `mysql` shell.

    > mysql -u root -p
    Enter password: ********

    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 64
    Server version: 5.6.23 MySQL Community Server (GPL)

    Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

    mysql> create database cbioportal;
    Query OK, 1 row affected (0.00 sec)

    mysql> create database cgds_test;
    Query OK, 1 row affected (0.00 sec)

    mysql> CREATE USER 'cbio_user'@'localhost' IDENTIFIED BY 'somepassword';
    Query OK, 0 rows affected (0.00 sec)

    mysql> GRANT ALL ON cbioportal.* TO 'cbio_user'@'localhost';
    Query OK, 0 rows affected (0.00 sec)

    mysql> GRANT ALL ON cgds_test.* TO 'cbio_user'@'localhost';
    Query OK, 0 rows affected (0.00 sec)

    mysql>  flush privileges;
    Query OK, 0 rows affected (0.00 sec)

#### Access mysql shell on docker container

To access the `mysql` shell on a docker container simply execute the following command:

```bash
docker exec -it "{CONTAINER_NAME}" mysql -p"{MYSQL-ROOT-PASSWORD}"
```

Where:    
- **{CONTAINER-NAME}**: The name of your container instance _i.e **cbio-DB**_.
- **{MYSQL-ROOT-PASSWORD}**: The root password for the MySQL installation. For password restrictions please read carefully this [link](http://dev.mysql.com/doc/refman/5.7/en/user-names.html).

### 2.3 Import the cBioPortal Database (Pending)

coming soon ...

## 3. cBioPortal Setup (Pending)

### 3.1 Prepare Configuration files (Pending)

Coming soon...
- [portal.properties](docs/Pre-Build-Steps.md#prepare-property-files)
- [log4j.properties](docs/Pre-Build-Steps.md#prepare-the-log4jproperties-file)
- [settings.xml](docs/Pre-Build-Steps.md#create-a-maven-settings-file)
- [context.xml](docs/Deploying.md#set-up-the-database-connection-pool)
- gene_sets.txt (optional) | Pending
- Logos (optional) | Pending

### 4.2 Run the cBioPortal docker container 

```bash
docker run -d --name "{CONTAINER-NAME}" \
    --restart=always \
    --net="{DOCKER-NETWORK-NAME}" \
    -p "{PREFERRED-EXTERNAL-PORT}":8080 \
    -v "{/PATH/TO/portal.properties}":/cbioportal/src/main/resources/portal.properties:ro \
    -v "{/PATH/TO/log4j.properties}":/cbioportal/src/main/resources/log4j.properties:ro \
    -v "{/PATH/TO/settings.xml}":/root/.m2/settings.xml:ro \
    -v "{/PATH/TO/context.xml}":/usr/local/tomcat/conf/context.xml:ro \
    -v "{/PATH/TO/CBIOPORTAL-LOGS}":/cbioportal_logs/ \
    -v "{/PATH/TO/TOMCAT-LOGS}":/usr/local/tomcat/logs/ \
    -v "{/PATH/TO/STUDIES}":/cbioportal_studies/:ro \
    cbioportal/cbioportal:{TAG}
```

Where:    
- **{CONTAINER-NAME}**: The name of your container instance, _i.e **cbio-DB**_.
- **{DOCKER-NETWORK-NAME}**: The name of your network, _i.e **cbioportal-net**_.
- **{PREFERRED-EXTERNAL-PORT}**: The port that the container internal port will be mapped to, _i.e **8306**_.
- **{/PATH/TO/portal.properties}**: The external path were portal.properties are stored.
- **{/PATH/TO/log4j.properties}**: The external path were log4j.properties are stored.
- **{/PATH/TO/settings.xml}**: The external path were settings.xml is stored.
- **{/PATH/TO/context.xml}**: The external path were context.xml is stored.
- **{/PATH/TO/CUSTOMIZATION}**: The external path were customization files are stored.
- **{/PATH/TO/CBIOPORTAL-LOGS}**: The external path where you want cBioPortal Logs to be stored.
- **{/PATH/TO/TOMCAT-LOGS}**: The external path where you want Tomcat Logs to be stored.
- **{/PATH/TO/STUDIES}**: The external path where cBioPortal studies are stored.
- **{TAG}**: The cBioPortal Version that you would like to run, _i.e **latest**_.


































## 2. Create a docker network

Because MySQL and cBioPortal are running on separate containers, Docker needs to know how to link them. Using Docker's legacy --link flag tends to be fragile since it will break if the MySQL container is restarted. We can get around this by using the newer *‘Docker networks’* feature.

```bash
	docker network create "{DOCKER_NETWORK_NAME}"
```
Where:    
**{DOCKER_NETWORK_NAME}** is the name of the network that cBioPortal and the cBioPortal DB are going to be accessible.

i.e If the network is called "cbioportal_network" the command should be:

```bash
	docker network create "cbioportal_network"
```

Running the above command will create a docker network called "cbioportal_network".

- Learn more on [docker container networking](https://docs.docker.com/engine/userguide/networking/).
- Learn more on [docker network create](https://docs.docker.com/engine/reference/commandline/network_create/).

## 3. Database Setup

As of this writing, the cBioPortal Database supports MySQL 5.7 and above.    

There are two options to set up the cBioPortal Database:    
- Run MySQL cBioPortal Database on the host.    
- Run MySQL cBioPortal Database using Docker.    

### 3.1 MySQL Configuration

### 3.1.1 Run MySQL on the host

To install MySQL 5.7, kindly follow the vendor’s official detailed installation guide, available [here](http://dev.mysql.com/doc/refman/5.7/en/installing.html).

### 3.1.2 Run MySQL as a docker container

In a docker terminal type the following command

```bash
	docker run -d --name "{CONTAINER_NAME}" \
    --restart=always \
    --net="{DOCKER_NETWORK_NAME}" \
    -p {PREFERRED_EXTERNAL_PORT}:3306 \
    -e MYSQL_ROOT_PASSWORD={MYSQL_ROOT_PASSWORD} \
    -e MYSQL_USER={MYSQL_USER} \
    -e MYSQL_PASSWORD={MYSQL_PASSWORD} \
    -e MYSQL_DATABASE={MYSQL_DATABASE} \
    -v {/PATH/TO/cbioportal-seed.sql.gz}:/docker-entrypoint-initdb.d/cbioportal-seed.sql.gz:ro \
    mysql
```

Where:    
- **{CONTAINER_NAME}**: The name of your container instance i.e cbio_DB
- **{DOCKER_NETWORK_NAME}**: The name of your network i.e cbioportal_network
- **{PREFERRED_EXTERNAL_PORT}**: The port that the container internal port will be mapped to i.e 8306
- **{MYSQL_ROOT_PASSWORD}**: The root password for the MySQL installation. For password restrictions please read carefully this [link](http://dev.mysql.com/doc/refman/5.7/en/user-names.html)
- **{MYSQL_USER}**: The MySQL user name i.e cbio_user
- **{MYSQL_PASSWORD}**: The MySQL user password i.e P@ssword1 . For password restrictions please read carefully this [link](http://dev.mysql.com/doc/refman/5.7/en/user-names.html)
- **{MYSQL_DATABASE}**: The MySQL Database Name i.e cbioportal
- **{/PATH/TO/cbioportal-seed.sql.gz}**: The actual absolute filepath were the cbioportal-seed.sql.gz file is stored on the machine that has docker installed.

Running the above command will create a MySQL docker container and will automatically import the Seed Database.
Please note that the Seed Database import can take some time.


#### MySQL Logs monitoring in Docker

MySQL logs can easily be monitored by executing the following command on a terminal with docker.

```bash
	docker logs {CONTAINER_NAME}
```

Where:    
- **{CONTAINER_NAME}**: The name of your container instance i.e cbio_DB

- Learn more on [docker logs](https://docs.docker.com/engine/reference/commandline/logs/).

#### Useful Resources

[MySQL Docker Hub](https://hub.docker.com/_/mysql/)    
[MySQL Docker Github](https://github.com/docker-library/docs/tree/master/mysql)

### 3.2 Create the cBioPortal MySQL Databases and User

You must create a `cbioportal` database and a `cgds_test` database within MySQL, and a user account with rights to access both databases.  This is done via the `mysql` shell.

    > mysql -u root -p
    Enter password: ********

    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 64
    Server version: 5.6.23 MySQL Community Server (GPL)

    Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

    mysql> create database cbioportal;
    Query OK, 1 row affected (0.00 sec)

    mysql> create database cgds_test;
    Query OK, 1 row affected (0.00 sec)

    mysql> CREATE USER 'cbio_user'@'localhost' IDENTIFIED BY 'somepassword';
    Query OK, 0 rows affected (0.00 sec)

    mysql> GRANT ALL ON cbioportal.* TO 'cbio_user'@'localhost';
    Query OK, 0 rows affected (0.00 sec)

    mysql> GRANT ALL ON cgds_test.* TO 'cbio_user'@'localhost';
    Query OK, 0 rows affected (0.00 sec)

    mysql>  flush privileges;
    Query OK, 0 rows affected (0.00 sec)

#### Access mysql shell on docker container

To access the `mysql` shell on a docker container simply execute the following command:

```bash
	docker exec -it {CONTAINER_NAME} mysql
```

Where:    
- **{CONTAINER_NAME}**: The name of your container instance i.e cbio_DB

### 3.3 Import the cBioPortal Database (Pending)

coming soon ...

## 4. cBioPortal Setup (Pending)

### 4.1 Prepare Configuration files (Pending)

Coming soon...
- [portal.properties](docs/Pre-Build-Steps.md#prepare-property-files)
- [log4j.properties](docs/Pre-Build-Steps.md#prepare-the-log4jproperties-file)
- [settings.xml](docs/Pre-Build-Steps.md#create-a-maven-settings-file)
- [context.xml](docs/Deploying.md#set-up-the-database-connection-pool)
- gene_sets.txt (optional) | Pending
- Logos (optional) | Pending

### 4.2 Run the cBioPortal docker container 

```bash
docker run -d --name "{CONTAINER_NAME}" \
    --restart=always \
    --net={DOCKER_NETWORK_NAME} \
    -p {PREFERRED_EXTERNAL_PORT}:8080 \
    -v {/PATH/TO/portal.properties}:/cbioportal/src/main/resources/portal.properties:ro \
	-v {/PATH/TO/log4j.properties}:/cbioportal/src/main/resources/log4j.properties:ro \
	-v {/PATH/TO/settings.xml}:/root/.m2/settings.xml:ro \
	-v {/PATH/TO/context.xml}:/usr/local/tomcat/conf/context.xml:ro \
	-v {/PATH/TO/CBIOPORTAL_LOGS}:/cbioportal_logs/ \
	-v {/PATH/TO/TOMCAT_LOGS}:/usr/local/tomcat/logs/ \
    -v {/PATH/TO/STUDIES}:/cbioportal_studies/:ro \
    cbioportal/cbioportal:{TAG}
```

Where:    
- **{CONTAINER_NAME}**: The name of your container instance, i.e cbio_DB.
- **{DOCKER_NETWORK_NAME}**: The name of your network, i.e cbioportal_network.
- **{PREFERRED_EXTERNAL_PORT}**: The port that the container internal port will be mapped to, i.e 8306.
- **{/PATH/TO/portal.properties}**: The external path were portal.properties are stored.
- **{/PATH/TO/log4j.properties}**: The external path were log4j.properties are stored.
- **{/PATH/TO/settings.xml}**: The external path were settings.xml is stored.
- **{/PATH/TO/context.xml}**: The external path were context.xml is stored.
- **{/PATH/TO/CUSTOMIZATION}**: The external path were customization files are stored.
- **{/PATH/TO/CBIOPORTAL_LOGS}**: The external path where you want cBioPortal Logs to be stored.
- **{/PATH/TO/TOMCAT_LOGS}**: The external path where you want Tomcat Logs to be stored.
- **{/PATH/TO/STUDIES}**: The external path where cBioPortal studies are stored.
- **{TAG}**: The cBioPortal Version that you would like to run, i.e latest