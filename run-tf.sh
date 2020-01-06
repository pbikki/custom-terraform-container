#!/bin/bash
# env
set -x
set -eu -o pipefail
set -e  



terraform version
ls ~/.terraform.d/plugins



cd terraform-files

terraform init -input=false

#  Terraform code
terraform fmt # Checks if the input is formatted. Exit status will be 0 if all input is properly formatted and non-zero otherwise
#terraform validate -check-variables=true # the command will check whether all required variables have been specified
terraform plan -out=tfplan


# SECONDS is a bash special variable that returns the seconds since set.
TF_START_TIME=$SECONDS
terraform apply -input=false tfplan 
export APPLY_TIME=$(($SECONDS - $TF_START_TIME))
# Now `APPLY_TIME` has the number of seconds for apply command to finish.
echo "Time taken to provision (seconds): $APPLY_TIME"


