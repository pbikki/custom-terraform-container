
provider "ibm" {
    ibmcloud_api_key    = "${var.ibmcloud_api_key}"
    iaas_classic_username = "${var.iaas_classic_username}"
    iaas_classic_api_key  = "${var.iaas_classic_api_key}"
}


resource "ibm_compute_vm_instance" "terraform-sample-flavor" {
    hostname = "${var.hostname}"
    domain = "${var.domain}"
    os_reference_code = "${var.os_reference_code}"
    datacenter = "${var.datacenter}" 
    //network_speed = 100 
    hourly_billing = "${var.hourly_billing}"
    local_disk = "${var.local_disk}"
    private_network_only = "${var.private_network_only}"
    public_vlan_id = "${var.public_vlan_id}"
    private_vlan_id = "${var.private_vlan_id}"
    flavor_key_name = "${var.gpu_flavor}"
    //user_metadata = "{\\\"value\\\":\\\"newvalue\\\"}"
    // provide disk 3, 4, 5 and so on
    //disks = [100]
    tags = "${var.tags}"
    //ipv6_enabled = true
    //secondary_ip_count = 4
    notes = "${var.notes}"
}


