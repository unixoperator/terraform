module "account_info" {
    source="../../../modules/account_info"
}

output "account_details" {
    value=module.account_info.outputs
}