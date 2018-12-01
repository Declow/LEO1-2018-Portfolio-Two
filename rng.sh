#!/bin/bash
#We changed the script to echo the result
echo dd if=/dev/random bs=4 count=16 status=none | od -A none -t u4