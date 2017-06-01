#!/bin/bash -ex
# ---
# RightScript Name: Google - Remove instance from targetPool
# Description: Adds current instance to targetPool
# Inputs:
#   GCE_SERVICE_ACCOUNT:
#     Category: GCE
#     Description: The GCE Service Account to use to add/remove the instance to the
#       targetPool.
#     Input Type: single
#     Required: true
#     Advanced: false
#   GCE_SERVICE_ACCOUNT_JSON:
#     Category: GCE
#     Description: The GCE Service Account Private Key JSON to use to add/remove the
#       instance to the targetPool.
#     Input Type: single
#     Required: true
#     Advanced: false
#   TARGET_POOL:
#     Category: GCE
#     Description: The targetPool name to add/remove the instance to.
#     Input Type: single
#     Required: true
#     Advanced: false
# Attachments: []
# ...

private_key="/home/rightlink/gce_service_account.json"

# Save Private Key JSON to File
echo $GCE_SERVICE_ACCOUNT_JSON | tee $private_key > /dev/null

# Authorize gcloud to use a Service Account to add itself to the targetPool
gcloud auth activate-service-account $GCE_SERVICE_ACCOUNT --key-file=$private_key

# Get Instance Name
instance_name=`curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google"`


instance_zone=`curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | awk -F'/' '{print $NF}'`

# Remove instance to pool
gcloud compute target-pools remove-instances $TARGET_POOL --instances $instance_name --instances-zone $instance_zone
