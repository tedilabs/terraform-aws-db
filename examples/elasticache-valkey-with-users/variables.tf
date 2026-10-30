variable "user_passwords" {
  description = "Passwords for the admin and readonly Valkey users. Supply these through your deployment's secret input mechanism."
  type = object({
    admin    = string
    readonly = string
  })
  sensitive = true
  nullable  = false

  validation {
    condition = alltrue([
      for password in values(var.user_passwords) :
      length(password) >= 16 && length(password) <= 128
    ])
    error_message = "Each user password must contain 16 to 128 characters."
  }
}
