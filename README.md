# ansible-cb-telemetry-manager

[![Docker Pulls](https://img.shields.io/docker/pulls/oleewere/ansible-cb-telemetry-manager.svg)](https://hub.docker.com/r/oleewere/ansible-cb-telemetry-manager/)
[![](https://images.microbadger.com/badges/image/oleewere/ansible-cb-telemetry-manager.svg)](https://microbadger.com/images/oleewere/ansible-cb-telemetry-manager "")

## Overview

This repo is providing playbooks for upgrading `cdp-telemetry` and `cdp-logging-agent` binaries by ansible (for providing only `salt-master` host).

## Requirements:

Install ansible (2.4.x -) 
```bash
pip install ansible
```
You can use docker as well:
```bash
# pull the docker image
docker pull oleewere/ansible-cb-telemetry-manager:latest
# or build it to yourself
docker build -t oleewere/ansible-cb-telemetry-manager:latest .
```

From that point you can use docker-compose or docker to run ansible commands like:
```bash
# use docker run
docker run --rm oleewere/ansible-cb-telemetry-manager:latest ansible -i hosts.sample salt-master -m shell -a 'echo hello'
# or use with docker-compose (files are on volume)
docker-compose run ansible-cb-telemetry-manager ansible -i hosts.sample salt-master -m shell -a 'echo hello'

- Note 1.: the examples does not contain the docker or docker-compose prefixes. 
- Note 2: `.env` file can be defined in the project folder, there you can set `SSH_KEYS_LOCATION`, which will be passed as a volume folder with the docker-compose

## Setup