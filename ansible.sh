#!/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install software-properties-common ansible -y

sudo apt autoremove -y