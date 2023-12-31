#!/bin/bash
image_ids=$(yc container image list --registry-id $1 | tail -n +4 | head -n -2 | awk '{print $2}' | tr "\n" " ")
if [ -n "$image_ids" ]; then
   yc container image delete ${image_ids[@]}
fi