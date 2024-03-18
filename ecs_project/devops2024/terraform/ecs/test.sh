#!/bin/bash
      echo test > test.out
      if grep -qEi 'debian|buntu|mint' /etc/os-release; then
        sudo apt-get update && sudo apt-get install -y putty
      elif grep -qEi 'fedora|centos|redhat|amzn' /etc/os-release; then
        sudo yum install -y putty
      else
        echo "Unsupported OS/Distro for automatic putty installation"
      fi
