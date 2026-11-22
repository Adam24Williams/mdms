---
name: jamf-pro-terraform-erase
description: Use when testing check-skills.
metadata:
  verified-against: "Jamf Pro 11.x, jamfplatform 1.10.0, Terraform 1.14"
  verified-on: "2026-11-21"
---

Fixture.

```hcl
  action "jamfplatform_pro_enable_lost_mode" "lost" {
    config {}
  }
```
