# custom-terraform-container
Container image with terraform, ibm terraform provider plugin, and other IBM Cloud dev tools installed

This document briefly outlines few ways to use the docker image created for the purpose of running terraform plans without having to install ibm terraform provider plugin and some other dev tools locally. You can spin-up a container using this image and directly begin using IBM Terraform provider plugin and provision IBM Cloud resources

Image on docker hub - [custom-ibm-terraform](https://hub.docker.com/r/csphoenix/custom-ibm-terraform)

# Useful resources 
- [Provisioning a VM instance on IBM cloud using Terraform](https://ibm-cloud.github.io/tf-ibm-docs/v0.21.0/r/compute_vm_instance.html)
- [terraform-provider-ibm] (https://github.com/IBM-Cloud/terraform-provider-ibm)

# Use the image
## Run using Docker

```
docker pull csphoenix/custom-ibm-terraform:0.11.14-0.21
```

File `tf-variables.env` looks something the below. These variables are supplied to the sample terraform plan `main.tf` inside the image that provisions a VSI with GPU. For details on how these env variables are used by terraform, take a look at [Setting tf vars using environment variables](https://www.terraform.io/docs/configuration-0-11/variables.html#environment-variables)

```
TF_VAR_hostname=tf-gpu-1
TF_VAR_domain=example.com
TF_VAR_public_vlan_id=12345
TF_VAR_private_vlan_id=56789
TF_VAR_os_reference_code=UBUNTU_18_64
TF_VAR_ibmcloud_api_key=<platform_apikey>
TF_VAR_iaas_classic_username=<infra_username>
TF_VAR_iaas_classic_api_key=<infra_apikey>
```
- [Creating an API key](https://cloud.ibm.com/docs/iam?topic=iam-userapikey)
- [Creating classic infrastructure API keys](https://cloud.ibm.com/docs/iam?topic=iam-classic_keys)
- To obtain the vlan ids, you can use ibmcloud cli or ibmcloud console
    - `$ ibmcloud login -apikey=<apikey>`
    - `$ ibmcloud sl vlan list`. 
    - If you don't have the ibm tools installed locally, you can use the console to obtain vlan ids. Navigate to [vlans](https://cloud.ibm.com/classic/network/vlans) on your account and click on the vlan in the desired region, and use the ID number from the *browser URL*

```
docker run -it --rm --env-file=tf-variables.env csphoenix/custom-ibm-terraform:0.11.14-0.21
```
The above docker run command opens an interactive bash session. The container has terraform and ibm terraform providers installed. A sample terraform plan is also included in the image.

NOTE: If you run the script `run-tf.sh` as shown below, the terraform plan provided along with the image is executed and you might be billed accordingly. Take a look at the files before provisioning.

```
root@1ad9f9eddbcf:/workdir# ls
run-tf.sh  terraform-files
root@1ad9f9eddbcf:/workdir# ls terraform-files/
main.tf  variables.tf
root@1ad9f9eddbcf:/workdir# ./run-tf.sh 
```
The script `run-tf.sh` is wrapper script and is created for automating execution of various terraform commands like
```
terraform init
terraform plan
terraform apply
```
Instead of using the script, you can cd into the `terraform-files` directory and run the terraform commands as needed.

If the terraform apply is successful, it should show something like `Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`
Make sure to destroy it if it is created for testing purposes
```
root@1ad9f9eddbcf:/workdir# cd terraform-files/
root@1ad9f9eddbcf:/workdir/terraform-files# terraform destroy
```


## Run on a kubernetes/openshift cluster
```
oc new-project terraform
oc adm policy add-scc-to-user anyuid -z default
```
```
kubectl run custom-ibm-terraform-container -it --rm --restart=Never --image=csphoenix/custom-ibm-terraform:0.11.14-0.21 
If you don't see a command prompt, try pressing enter.
root@custom-ibm-terraform-container:/workdir# 
root@custom-ibm-terraform-container:/workdir# ./run-tf.sh 

```
Because variable values are not supplied through env vars, terraform will prompt to enter values for variables that do not have default values set. Enter the values as needed and then the terraform apply will be executed.
Make sure to do a destroy if created for testing
```
root@custom-ibm-terraform-container:/workdir# cd terraform-files
root@custom-ibm-terraform-container:/workdir/terraform-files# terraform destroy
```
Exit the pod
```
root@custom-ibm-terraform-container:/workdir# exit
exit
pod "custom-ibm-terraform-container" deleted
```
## Points to be noted
- The `main.tf` in the container image is only a sample terraform plan that provisions a VSI with GPU. It can be modified to have more options or new terraform files can be copied into the container for testing
- The variables like the operating system, VSI GPU flavor, datacenter are set to default values and can be overidden. For details, take a look into `variable.tf` file from the image
- The above steps show only one way to supply variable values to terrform plan. Other ways like using `tfvars` file or if running on a kube pod, a  config map can be created and thus the variables can be retrieved as env variables. More details can be found at [Input Variables](https://www.terraform.io/docs/configuration-0-11/variables.html)


# Build the image and run locally
```
├── Dockerfile
├── README.md
├── run-tf.sh
├── terraform-files
│   ├── main.tf
│   └── variables.tf
└── tf-variables.env
```

If you want to customize the image and have your own terraform plans in it, place your terraform files inside the `terraform-files` directory and re-build the image. The image can then be pushed to desired private registries. 

Make sure you are in the root directory of the repo

```
$ docker build -t custom-ibm-terraform .
```

```
$ docker run -it --rm --env-file=tf-variables.env custom-ibm-terraform
```

# Create a deployment on the cluster 

- Sample `deployment.yaml`, `secret.yaml` are provided in the `k8s_extra` directory
- They can be used to create a deployment instead of creating temporary containers like above
- Note that the deployment is designed to pull provider credentials from a secret
- So, a secret has to be created first or you can change your deployment accordingly and use other methods to supply credentials

```
├── k8s_extra
│   ├── deployment.yaml
│   └── secret.yaml
```

```
$ kubectl create -f secret.yaml
```

```
$ kubectl create -f deployment.yaml
```

Then, you can exec into the create pod, copy new terraform plans and execute them as you like

