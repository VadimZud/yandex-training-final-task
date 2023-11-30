#!/bin/bash

temp=$(yc config get cloud-id)
if [ -n "$temp" ]; then
   export TF_VAR_cloud_id=$temp
fi
temp=$(yc config get folder-id)
if [ -n "$temp" ]; then
   export TF_VAR_folder_id=$temp
fi
temp=$(yc config get compute-default-zone)
if [ -n "$temp" ]; then
   export TF_VAR_zone=$temp
fi
temp=$(yc iam create-token)
if [ -n "$temp" ]; then
   export TF_VAR_token=$temp
fi