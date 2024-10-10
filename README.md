# crowdsec

[![Puppet Forge](http://img.shields.io/puppetforge/v/bzed/crowdsec.svg)](https://forge.puppet.com/bzed/crowdsec)

Management of a crowdsec infrastructure using puppet.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with crowdsec](#setup)
    * [What crowdsec affects](#what-crowdsec-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with crowdsec](#beginning-with-crowdsec)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

bzed-crowdsec installs and manages crowdsec.
The current state is: deep in development. Some basic functions, more to come. Send patches!

## Setup

### Beginning with crowdsec

FIXME

## Usage

FIXME

## Reference

An html version of the reference is available here: https://bzed.github.io/bzed-crowdsec/
There is also a markdown version in REFERENCE.md

## Limitations

** THIS MODULE IS FAR FROM FINISHED **

## Development

Please use the github issue tracker and send pull requests. Make sure that your pull requests keep pdk validate/test unit happy!

### For a release:
 -  Update gh\_pages:

        bundle exec rake strings:gh_pages:update

 -  Update REFERENCE.md:

        puppet strings generate --format markdown --out REFERENCE.md

 -  Release:

        pdk build

 -  Bump version number: bump/change the version in metadata.json.

### Support and help
There is no official commercial support for this puppet module, but I'm happy to help you if you open a bug in the issue tracker.
Please make sure to add enough information about what you have done so far and how your setup looks like.
I'm also reachable by [email](mailto:bernd@bzed.de). Use GPG to encrypt confidential data:

    ECA1 E3F2 8E11 2432 D485  DD95 EB36 171A 6FF9 435F

If you are happy, I also have an [amazon wishlist](https://www.amazon.de/registry/wishlist/1TXINPFZU79GL) :)
