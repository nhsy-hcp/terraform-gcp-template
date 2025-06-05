#!/usr/bin/env bash

BUCKET=terraform-state-$(gcloud config get-value project)
REGION=$(gcloud config get-value compute/region)

result=$(gsutil list | grep "${BUCKET}")
if [ -z "$result" ]; then
  echo Creating terraform state bucket: $BUCKET
  gsutil mb -b on -l $REGION gs://$BUCKET
  gsutil versioning set on gs://$BUCKET
else
  echo Skipping terraform state bucket creation: $BUCKET
fi
echo