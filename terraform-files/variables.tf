variable "iaas_classic_username" {
  description = "Enter the user name to access IBM Cloud classic infrastructure. You can retrieve the user name by following the instructions for retrieving your classic infrastructure API key."
}

variable "iaas_classic_api_key" {
  description = "Enter the API key to access IBM Cloud classic infrastructure. For more information for how to create an API key and retrieve it, see [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/iam?topic=iam-classic_keys)."
}

variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://cloud.ibm.com/iam#/apikeys"
}


variable "hostname" {
    description = "The hostname for the computing instance"
    default =   "tf-gpu"
}

variable "domain" {
    description = "The domain for the computing instance"
    default = "bar.example.com"
}

variable "os_reference_code" {
  description = "The operating system reference code that is used to provision the computing instance"
  default   =   "UBUNTU_18_64"
}

variable "datacenter" {
  description   =   "The datacenter in which you want to provision the instance"
  default   =   "fra02"
}

variable "hourly_billing" {
    description =   "The billing type for the instance. When set to true, the computing instance is billed on hourly usage. Otherwise, the instance is billed on a monthly basis."
    default = true
}

variable "local_disk" {
    description =   "The disk type for the instance. When set to true, the disks for the computing instance are provisioned on the host that the instance runs. Otherwise, SAN disks are provisioned"
    default = true
}
variable "private_network_only" {
    description =   "When set to true, a compute instance only has access to the private network. The default value is false"
    default = false
}


variable "public_vlan_id" {
    description =   "The public VLAN ID for the public network interface of the instance"
}

variable "private_vlan_id" {
    description =   "The private VLAN ID for the private network interface of the instance"
}

variable "gpu_flavor" {

    description =   "The flavor key name that you want to use to provision the instance"
    default =   "ACL2_8X60X100" //gpu V100
  
}

variable "tags" {
  type        = "list"
  description = "Tags for instance"
  default     = ["terraform", "gpu-test"]
}

variable "notes" {
    description =   "Descriptive text of up to 1000 characters about the VM instance"
    default = "gpu terraform test"
}