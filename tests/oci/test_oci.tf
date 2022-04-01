terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

module "transit_non_ha_oci" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "oci"
  name                   = "transit-non-ha-oci"
  region                 = "eu-central-1"
  cidr                   = "10.1.0.0/23"
  account                = "OCI"
  ha_gw                  = false
  enable_transit_firenet = true
}

module "mc_firenet_non_ha_oci" {
  source = "../.."

  transit_module = module.transit_non_ha_oci
  firewall_image = "Palo Alto Networks VM-Series Next Generation Firewall"
  egress_enabled = true
}

module "transit_ha_oci" {
  source = "git::https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-transit.git" #Needs to be version pinned after mc-transit 2.0 release

  cloud                  = "oci"
  name                   = "transit-ha-oci"
  region                 = "eu-central-1"
  cidr                   = "10.2.0.0/23"
  account                = "OCI"
  enable_transit_firenet = true
}

module "mc_firenet_ha_oci" {
  source = "../.."

  transit_module = module.transit_ha_oci
  firewall_image = "Palo Alto Networks VM-Series Next Generation Firewall"
  egress_enabled = true
}

resource "test_assertions" "cloud_type_non_ha" {
  component = "cloud_type_non_ha_oci"

  equal "cloud_type_non_ha" {
    description = "Module output is equal to check map."
    got         = module.transit_non_ha_oci.transit_gateway.cloud_type
    want        = 16
  }
}

resource "test_assertions" "cloud_type_ha" {
  component = "cloud_type_ha_oci"

  equal "cloud_type_ha" {
    description = "Module output is equal to check map."
    got         = module.transit_ha_oci.transit_gateway.cloud_type
    want        = 16
  }
}