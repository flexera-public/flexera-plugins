#!/bin/bash -ex
# ---
# RightScript Name: NSX check port
# Inputs:
#   HOST:
#     Category: Uncategorized
#     Input Type: single
#     Required: true
#     Advanced: false
#   PORT:
#     Category: Uncategorized
#     Input Type: single
#     Required: true
#     Advanced: false
# Attachments: []
# ...

curl -v --noproxy '*' $HOST:$PORT
