#!/bin/bash

# Maximum wait time in seconds (e.g., 10 minutes)
MAX_WAIT=600
# Interval between checks in seconds
CHECK_INTERVAL=30

# Starting time
START_TIME=$(date +%s)

echo "Waiting for all nodes to become ready..."

while true; do
  # Check if all nodes are ready
  kubectl get nodes >> kube.log
  kubectl get nodes | awk '{if (NR!=1) {print $2}}' | grep -qv "Ready" >> kube.log
  if kubectl get nodes | awk '{if (NR!=1) {print $2}}' | grep -qv "Ready"; then
    echo "Not all nodes are ready yet. Waiting..."
  else
    echo "All nodes are ready."
    break
  fi
  
  # Check the elapsed time
  ELAPSED_TIME=$(($(date +%s) - START_TIME))
  if [ $ELAPSED_TIME -ge $MAX_WAIT ]; then
    echo "Timeout waiting for nodes to become ready."
    exit 1
  fi

  # Wait before the next check
  sleep $CHECK_INTERVAL
done



# #!/bin/bash
# set -e

# # Example check - Replace with actual readiness check
# until kubectl get nodes; do
#   echo "Waiting for Kubernetes cluster to be ready..."
#   sleep 90
# done

# # Output required by Terraform external data source
# echo '{"ready":true}'
