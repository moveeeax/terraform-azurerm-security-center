terraform {
  # Note: the test suite under tests/ uses `mock_provider`, which requires
  # Terraform >= 1.7 / OpenTofu >= 1.7. That is a contributor-only requirement
  # and is deliberately not encoded here so consumers on 1.5/1.6 still work.
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # `azurerm_security_center_contact` only gained the `name` argument in
      # azurerm 3.30.0 — on 3.0.0 through 3.29.0 this module fails to validate
      # with "An argument named \"name\" is not expected here."
      # The upper bound is deliberate: major azurerm releases remove
      # security-center resources (4.0 dropped
      # `azurerm_security_center_server_vulnerability_assessment`), so 5.x must
      # be opted into explicitly rather than silently.
      version = ">= 3.30, < 5.0"
    }
  }
}
