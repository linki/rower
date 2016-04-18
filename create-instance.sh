gcloud compute --project "serious-habitat-123456" instances create "coreos-rower-test" \
  --zone "europe-west1-d" \
  --machine-type "n1-standard-1" \
  --network "default" \
  --metadata-from-file kube-pods=example-userdata.yaml \
  --maintenance-policy "MIGRATE" \
  --scopes default="https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/cloud.useraccounts.readonly" \
  --image "/serious-habitat-123456/coreos-rower-v20160418" \
  --boot-disk-size "10" \
  --boot-disk-type "pd-ssd" \
  --boot-disk-device-name "coreos-rower-test"