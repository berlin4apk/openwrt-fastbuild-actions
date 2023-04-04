#!/bin/bash

sudo -E apt-get -qq install --no-upgrade genisoimage || $(sudo -E apt-get -qq update && sudo -E apt-get -qq install --no-upgrade genisoimage)

