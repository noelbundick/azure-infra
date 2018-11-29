# Azure Subscription - Global resources

## Getting your objectId

```bash
az ad user show --upn-or-object-id $(az account show --query user.name -o tsv) --query objectId -o tsv
```