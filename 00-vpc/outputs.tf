# output "azs_info" {
#     value = module.vpc.azs_info
# }

# output "subnet_info" {
#     value = module.vpc.subnets_info 
# }

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}