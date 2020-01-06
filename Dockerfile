#
# Dockerfile for Stability as a Service
#

FROM ubuntu:16.04


# Set this so apt-utils does not complain about "unable to initialize frontend: Dialog".
ARG DEBIAN_FRONTEND=noninteractive
# Create and set the working directory
ENV APP_HOME=/workdir
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# Install apt-utils to avoid package confiiguration warnings later.
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

# # Install bash calculator for floating point calculations.
# RUN apt-get update && apt-get install -y bc

# Install curl, wget, unzip
RUN apt-get update && apt-get install -y curl wget unzip vim


############## IBM Cloud Developer Tools (optional) #########

# Install the ibmcloud command line tools.
RUN curl -sL https://ibm.biz/idt-installer | bash
RUN ibmcloud config --check-version=false



################ Terraform ####################

# Provide version of terraform you want to install in your container
ENV TERRAFORM_VERSION 0.11.14

# Download given version of the terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# Extract the downloaded file archive
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# Add permissions on terraform executable
RUN chmod +x terraform
# Move the executable into a directory searched for executables and remove the downloaded file
RUN mv terraform /usr/local/bin/ \
&& rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip



################ IBM Terraform Provider ####################
# Provide version of ibm terraform provider you want to install in your container
ENV TERRAFORM_IBMCLOUD_VERSION 0.21.0
# Download given version of the ibm terraform provider
RUN wget https://github.com/IBM-Cloud/terraform-provider-ibm/releases/download/v${TERRAFORM_IBMCLOUD_VERSION}/linux_amd64.zip
# Extract the downloaded file archive
RUN unzip linux_amd64.zip
# Add permissions on executables
RUN chmod +x terraform-provider-ibm_*
# Since IBM provider is a third party plugin, you need to place the plugin a specific directory `~/.terraform.d/plugins`
# Create the directories as required by terraform
RUN mkdir ~/.terraform.d
RUN mkdir ~/.terraform.d/plugins
# Move the binary into the Terraform plugins directory and remove the downloaded file
RUN mv terraform-provider-ibm_* ~/.terraform.d/plugins \
&& rm -rf linux_amd64.zip

########################  Add code files   #####################################

# Add terrform-files directory from local (place terraform plan files that should be run in this directory)
ADD terraform-files $APP_HOME/terraform-files


# Add the script used by entrypoint script to run the terraform plan and provision the resources 
ADD run-tf.sh $APP_HOME

# Allow executing the following files 

RUN chmod +x $APP_HOME/run-tf.sh

# Ensure APP_HOME is accessible by the root group
RUN chmod -R g=u $APP_HOME

# # Provide Entry point
ENTRYPOINT [ "/bin/bash" ]
