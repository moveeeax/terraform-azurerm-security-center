# terraform-azurerm-security-center

Terraform module that configures [Microsoft Defender for Cloud](https://azure.microsoft.com/products/defender-for-cloud)
(formerly Azure Security Center) at the subscription level. It sets the pricing
tier for a map of resource types and, optionally, configures a security contact
for alert notifications.

## Usage

```hcl
module "security_center" {
  source = "github.com/moveeeax/terraform-azurerm-security-center?ref=v1.0.0"

  resource_types = {
    VirtualMachines = "Standard"
    StorageAccounts = "Standard"
  }

  contact = {
    name  = "security-team"
    email = "security@example.com"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Behaviour worth knowing

- `resource_types` is **required and must be non-empty**. Defender for Cloud
  pricing is subscription-wide, so a module call with no resource types would
  apply cleanly and enable no protection at all; that is rejected at plan time
  rather than silently accepted.
- `Standard` enables (and bills for) a plan; `Free` disables it. Removing a key
  from `resource_types` destroys the pricing resource, which the provider
  implements by resetting that plan to `Free` — i.e. removing an entry turns
  the plan off.
- The security contact is validated: the email must be well formed, and at
  least one of `alert_notifications` / `alerts_to_admins` must remain enabled.
  A contact with neither is created successfully but never delivers an alert.

## Requirements

| Name      | Version          |
|-----------|------------------|
| terraform | >= 1.5           |
| azurerm   | >= 3.30, < 6.0   |

`azurerm_security_center_contact` only gained the `name` argument in azurerm
**3.30.0**; on 3.0.0–3.29.0 this module fails `terraform validate`. The `< 6.0`
ceiling is deliberate — azurerm major releases remove security-center
resources (4.0 dropped `azurerm_security_center_server_vulnerability_assessment`,
5.0 dropped `azurerm_security_center_auto_provisioning`; the module uses
neither). 5.x has been validated and tested; 6.x must be opted into knowingly.

## Inputs

| Name             | Description                                                     | Type          | Default | Required |
|------------------|-----------------------------------------------------------------|---------------|---------|:--------:|
| `resource_types` | Map of resource types to their pricing tier (Free or Standard). | `map(string)` | n/a     |   yes    |
| `contact`        | Optional security contact for the subscription.                 | `object`      | `null`  |    no    |

### `contact` object

| Attribute             | Type     | Default | Description                                        |
|-----------------------|----------|---------|----------------------------------------------------|
| `name`                | `string` | n/a     | Contact name. Required, non-empty.                 |
| `email`               | `string` | n/a     | Alert destination. Required, must be well formed.  |
| `phone`               | `string` | `null`  | Optional phone number.                             |
| `alert_notifications` | `bool`   | `true`  | Send alerts to the contact email.                  |
| `alerts_to_admins`    | `bool`   | `true`  | Send alerts to subscription admins.                |

## Outputs

| Name          | Description                                                        |
|---------------|--------------------------------------------------------------------|
| `pricing_ids` | Map of resource types to their Defender for Cloud pricing IDs.      |
| `contact_id`  | ID of the security center contact, if one was created.             |

## Development

The test suite runs against a mocked provider — no Azure credentials, no
network:

```sh
terraform init -backend=false
terraform test
```

`mock_provider` requires Terraform / OpenTofu >= 1.7. That is a contributor-only
requirement; consumers of the module still only need >= 1.5.

## License

[MIT](LICENSE)
