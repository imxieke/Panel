#!/bin/bash

# Download the file
wget -c http://dl.wdcp.net/files/lanmp.tar.gz

# Extract the downloaded archive
tar zxvf lanmp.tar.gz

# Run the lanmp.sh script with the "cus" argument
sh lanmp.sh cus
