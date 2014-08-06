```bash
     \    _)             |                 |
    _ \    |   __|  __|  __|   _` |   __|  |  /
   ___ \   |  |   \__ \  |    (   |  (       <
 _/    _\ _| _|   ____/ \__| \__,_| \___| _|\_\
```


# TODO

- write install script
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

#### OSX

* [Homebrew](http://brew.sh/): `brew install node`
* or [NVM](https://github.com/creationix/nvm)

#### Linux

* [Download](http://nodejs.org/download/)


### boot2docker

#### OSX

* [install package](http://docs.docker.com/installation/mac/)

#### Linux

Linux requires VirtualBox for now. Native support will be added once
OSX CLI is stable.

* [manual install](https://github.com/boot2docker/boot2docker#installation)


### airstack images

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
git clone git@github.com:airstackio/cli.git
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


