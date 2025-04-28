# variable "users" {
#   type = map(object({
#     policies = optional(list(string), [])
#     inline_policy = optional(object({
#       name   = string
#       policy = string
#     }))
#     kms_keys = optional(list(string), [])
#   }))
# }

variable "users" {
  type = map(object({
    policies = optional(list(string), [])
    kms_keys = optional(list(string), [])
  }))
}