variable "resource_types" {
  description = <<-EOT
    Map of Defender for Cloud resource types to their pricing tier, keyed by
    resource type (e.g. VirtualMachines, StorageAccounts). Tier must be
    "Standard" (the plan is enabled and billed) or "Free" (the plan is
    disabled). At least one entry is required: an empty map would make this
    module apply cleanly while enabling no protection at all.
  EOT
  type        = map(string)

  validation {
    condition     = length(var.resource_types) > 0
    error_message = "resource_types must contain at least one entry. An empty map enables no Defender for Cloud plans, so the module would apply cleanly and protect nothing."
  }

  validation {
    condition     = alltrue([for tier in values(var.resource_types) : contains(["Free", "Standard"], tier)])
    error_message = "Each pricing tier must be one of Free or Standard."
  }

  validation {
    condition     = alltrue([for type in keys(var.resource_types) : length(trimspace(type)) > 0])
    error_message = "resource_types keys must be non-empty Defender for Cloud resource type names."
  }
}

variable "contact" {
  description = <<-EOT
    Optional security contact for the subscription. Null disables contact
    creation. When set, `email` must be a real address and at least one of
    `alert_notifications` / `alerts_to_admins` must stay enabled, otherwise the
    contact is created but Defender for Cloud never reaches anyone.
  EOT
  type = object({
    name                = string
    email               = string
    phone               = optional(string, null)
    alert_notifications = optional(bool, true)
    alerts_to_admins    = optional(bool, true)
  })
  default = null

  validation {
    condition     = var.contact == null ? true : length(trimspace(var.contact.name)) > 0
    error_message = "contact.name must be a non-empty string."
  }

  validation {
    condition     = var.contact == null ? true : can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.contact.email))
    error_message = "contact.email must be a valid email address. Defender for Cloud alerts are delivered to this address, so a blank or malformed value silently notifies nobody."
  }

  validation {
    condition     = var.contact == null ? true : (var.contact.alert_notifications || var.contact.alerts_to_admins)
    error_message = "contact must keep at least one of alert_notifications or alerts_to_admins enabled. With both disabled the contact resource is created but no alert is ever delivered."
  }
}
