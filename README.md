```bash
     \    _)             |                 |
    _ \    |   __|  __|  __|   _` |   __|  |  /
   ___ \   |  |   \__ \  |    (   |  (       <
 _/    _\ _| _|   ____/ \__| \__,_| \___| _|\_\
```


# TODO

- Samba
  - X add mounts to samba conf
  - X reload samba on conf change
  - clean up smbd.conf on reload
  - truncate smbd logs
- CLI dashboard
  - output status of host processes: samba, virtualbox, etc.
  - keyboard support for switching between monitor and log view
  - status of containers
- Logging
  - bind logger on vbox host ip address: https://github.com/airstack/airstack/blob/master/airsdk/base/make/init_share.sh
  - pipe container logs to syslog service on host
- Stats
  - use pidusage.js as example for parsing proc data of containers for stats
- `air up`
  - add start command to runit script
  - docker run
- `air ssh <container>`
- `air down`
- `air restart <container>`
- tab completion for container names
- Install script
  - download node v0.11 into ~/.airstack/bin/node
  - http://nodejs.org/dist/
  - use nvm install as template: https://github.com/creationix/nvm/blob/master/install.sh



# Overview

Airstack CLI is similar to [Heroku's toolbelt CLI](https://toolbelt.heroku.com/).

It provides a convenient method for fetching containers for dev, configuring and deploying.


# Bechmark

Airstack CLI should be intuitive and easy to learn for junior developers and anyone new to Airstack.
It should also be powerful enough to develop and manage an entire app cluster of 1,000 nodes.


# Focus

For MVP, the CLI focuses on the NodeJS community.


# Requirements

### NodeJS

Node >=0.10 is required.

Use 0.10.30 until 0.11 is stable. There seems to be an issue with child_process.exec
hanging on 0.11. This issue shows up occasionally when exiting `air up`. The
pgrep exec will sometimes not return results or timeout properly.

1. Install [NVM](https://github.com/creationix/nvm)
2. `nvm use 0.10.30`

### Boot2Docker

**OSX**: [install package](http://docs.docker.com/installation/mac/)

**Linux**: [manual install](https://github.com/boot2docker/boot2docker#installation)

Linux requires VirtualBox for now. Native support will be added once
OSX CLI is stable.

### Samba

OSX: `brew install samba`

See [samba doc](https://github.com/airstack/docs/blob/master/samba.md).

### Airstack Images

The CLI expects Docker images to already be available in the VM.
Normally, the CLI would download the images as needed from the Airstack
Docker index. Until the index is stable, simply clone the images repo
and manually build each image.

```bash
# Make sure boot2docker is first running
boot2docker up

# Clone repo and make images
git clone git@github.com:airstack/airstack.git
cd airstack/base
make build
cd ../nodejs
make build
```


# Installation

```bash
git clone git@github.com:airstack/cli.git
cd cli
npm install
npm link

# Test
air up

# Or
air -h
```


# Resources

* [Creating a CLI in Node](http://michaelbrooks.ca/deck/jsconf2013/)


