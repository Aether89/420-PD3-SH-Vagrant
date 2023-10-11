#!/bin/bash

sudo apt update
# sudo apt upgrade -y

sudo apt install python3-full python-is-python3 ansible expect -y

sudo apt autoremove -y
