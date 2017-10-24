#!/bin/bash -ex
# ---
# RightScript Name: Telstra - NXS check port
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
