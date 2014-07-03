# Overview

Airship CLI is similar to [Heroku's toolbelt CLI](https://toolbelt.heroku.com/).

It provides a convenient method for fetching containers for dev, configuring and deploying.


# Bechmark

Airship CLI should be intuitive and easy to learn for junior developers and anyone new to Airship.
It should also be powerful enough to develop and manage an entire app cluster of 1,000 nodes.


# Focus

For MVP, the CLI focuses on the NodeJS community.


# Pain Points

### Dependencies

In NodeJS, module dependency management is a pain. NPM does a decent job of fetching and updating dependencies, 
but that's it. There's no equivalent to Bundler's Gemfile.lock in Ruby which when used properly ensures 
identical gems are used across dev boxes and production.


# Prerequisites

For a Node CLI, node must already be installed.

* All: [Official Downloads](http://nodejs.org/download/)
* OSX: [Homebrew](http://brew.sh/): `brew install node`
* Virtual: [Nave](https://github.com/isaacs/nave) or [NVM](https://github.com/creationix/nvm)


# Resources

* [Creating a CLI in Node](http://michaelbrooks.ca/deck/jsconf2013/)
* 
