# Requires Terraform >= 1.7 / OpenTofu >= 1.7 for `mock_provider`.
# Runs with no Azure credentials and no network access.

mock_provider "azurerm" {}

variables {
  resource_types = {
    VirtualMachines = "Standard"
    StorageAccounts = "Standard"
  }
}

run "pricing_tiers_are_applied_verbatim" {
  assert {
    condition     = azurerm_security_center_subscription_pricing.this["VirtualMachines"].tier == "Standard"
    error_message = "VirtualMachines should be pinned to the Standard tier."
  }

  assert {
    condition     = azurerm_security_center_subscription_pricing.this["StorageAccounts"].resource_type == "StorageAccounts"
    error_message = "resource_type should be taken from the map key."
  }

  assert {
    condition     = length(azurerm_security_center_subscription_pricing.this) == 2
    error_message = "One pricing resource should be created per resource_types entry."
  }
}

run "contact_is_optional" {
  variables {
    contact = null
  }

  assert {
    condition     = length(azurerm_security_center_contact.this) == 0
    error_message = "A null contact must not create a security contact."
  }

  assert {
    condition     = output.contact_id == null
    error_message = "contact_id must be null when no contact is created."
  }
}

run "contact_defaults_notify_someone" {
  variables {
    contact = {
      name  = "security-team"
      email = "security@example.com"
    }
  }

  assert {
    condition     = azurerm_security_center_contact.this[0].alert_notifications
    error_message = "alert_notifications must default to true, otherwise the contact is created but never notified."
  }

  assert {
    condition     = azurerm_security_center_contact.this[0].alerts_to_admins
    error_message = "alerts_to_admins must default to true, otherwise subscription admins are never notified."
  }

  assert {
    condition     = azurerm_security_center_contact.this[0].email == "security@example.com"
    error_message = "The contact email must be passed through unchanged."
  }
}

run "rejects_empty_resource_types" {
  command = plan

  variables {
    resource_types = {}
  }

  expect_failures = [var.resource_types]
}

run "rejects_unknown_pricing_tier" {
  command = plan

  variables {
    resource_types = {
      VirtualMachines = "Premium"
    }
  }

  expect_failures = [var.resource_types]
}

run "rejects_blank_contact_email" {
  command = plan

  variables {
    contact = {
      name  = "security-team"
      email = ""
    }
  }

  expect_failures = [var.contact]
}

run "rejects_malformed_contact_email" {
  command = plan

  variables {
    contact = {
      name  = "security-team"
      email = "security-team"
    }
  }

  expect_failures = [var.contact]
}

run "rejects_contact_that_notifies_nobody" {
  command = plan

  variables {
    contact = {
      name                = "security-team"
      email               = "security@example.com"
      alert_notifications = false
      alerts_to_admins    = false
    }
  }

  expect_failures = [var.contact]
}

run "rejects_blank_contact_name" {
  command = plan

  variables {
    contact = {
      name  = "  "
      email = "security@example.com"
    }
  }

  expect_failures = [var.contact]
}
