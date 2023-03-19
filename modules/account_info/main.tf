data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_region" "current" {}
locals {
  region = data.aws_region.current.name
}

locals {
  aws_meta            = yamldecode(file("${path.module}/../../data/aws_meta.yaml"))
  accounts_info       = local.aws_meta["accounts"]
  regions_info        = local.aws_meta["regions"]
  account_name        = { for name, account_info in local.accounts_info : account_info["account_id"] => name }[local.account_id]
  region_info         = local.regions_info[local.region]
  account_ids         = toset([for _, account_info in local.accounts_info : account_info["account_id"]])
  account_alias_regex = local.aws_meta["_metadata"]["account_alias_regex"]
  account_info        = local.accounts_info[local.account_name]
  account_alias       = local.account_info["alias"]
  location            = regex(local.account_alias_regex, local.account_alias)["location"]
  account_owner       = local.location
  account_type        = regex(local.account_alias_regex, local.account_alias)["type"]
  env                 = regex(local.account_alias_regex, local.account_alias)["env"]
  az_letters          = local.regions_info[local.region]["availability_zones"]
  availability_zones  = [for letter in local.az_letters : "${local.region}${letter}"]
  region_alias        = local.region_info["alias"]
  region_aliases      = toset([for _, region_info in local.regions_info : region_info["alias"]])
  regions             = toset([for region, _ in local.regions_info : region])
  region_to_alias_map = { for region, region_info in local.regions_info : region => region_info["alias"] }
  alias_to_region_map = { for region, region_info in local.regions_info : region_info["alias"] => region }
  s3_prefix           = local.account_info["s3_prefix"]
}

output "account_id" {
  description = "AWS Account ID number of the account that owns or contains the calling entity."
  value       = local.account_id
}

output "account_ids" {
  description = "List of account ids."
  value       = local.account_ids
}

output "account_name" {
  description = "Name of the account."
  value       = local.account_name
}

output "account_type" {
  description = "Type of the account."
  value       = local.account_type
}

output "account_alias" {
  description = "Alias of the account."
  value       = local.account_alias
}

output "account_owner" {
  description = "Owner of the account."
  value       = local.account_owner
}

output "availability_zones" {
  description = "AZs in this region, e.g. 'us-east-2' --> {'us-east-2a', 'us-east-2b', 'us-east-2c'}."
  value       = local.availability_zones
}

output "env" {
  description = "'dev', or 'prd'."
  value       = local.env
}

output "location" {
  description = "'apac', 'ams', or 'us'."
  value       = local.location
}

output "region" {
  description = "Name of the selected region, e.g. 'us-east-2', 'us-east-1', etc."
  value       = local.region
}

output "region_alias" {
  description = "Shorthand name of the selected region, e.g. 'use2' for 'us-east-2', 'use1' for 'us-east-1', etc."
  value       = local.region_alias
}

output "region_aliases" {
  description = "List of region aliases."
  value       = local.region_aliases
}

output "regions" {
  description = "List of regions."
  value       = local.regions
}

output "region_to_alias_map" {
  description = "Map of region to region alias."
  value       = local.region_to_alias_map
}

output "alias_to_region_map" {
  description = "Map of region alias to region."
  value       = local.alias_to_region_map
}

output "s3_prefix" {
  description = "S3 prefix of the account."
  value       = local.s3_prefix
}

output "outputs" {
  value = {
    account_id          = local.account_id
    account_ids         = local.account_ids
    account_name        = local.account_name
    account_owner       = local.account_owner
    account_type        = local.account_type
    account_alias       = local.account_alias
    env                 = local.env
    location            = local.location
    availability_zones  = local.availability_zones
    region              = local.region
    regions             = local.regions
    region_alias        = local.region_alias
    region_aliases      = local.region_aliases
    region_to_alias_map = local.region_to_alias_map
    alias_to_region_map = local.alias_to_region_map
    s3_prefix           = local.s3_prefix
  }
}
