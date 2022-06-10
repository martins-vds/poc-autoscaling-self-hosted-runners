# Proof of Concept: Autoscaling Self Hosted Runners

> ⚠️ None of the resources deployed by this proof-of-concept are production-ready

## References

- <https://docs.github.com/en/actions/hosting-your-own-runners/autoscaling-with-self-hosted-runners>
- <https://github.com/actions-runner-controller/actions-runner-controller>
- <https://github.com/Tazmainiandevil/codingwithtaz/tree/master/azure/aks>

## How to Deploy this POC

### Configure deployment credentials

For using any credentials like Azure Service Principal, Publish Profile etc add them as [secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) in the GitHub repository and then use them in the workflow.

Follow the steps to configure Azure Service Principal with a secret:

- Define a new secret under your repository settings, Add secret menu
- Store the output of the below az cli command as the value of secret variable, for example 'AZURE_CREDENTIALS'

```bash
let "randomIdentifier=$RANDOM*$RANDOM"
servicePrincipalName="poc-autoscaling-self-hosted-runners-$randomIdentifier"
subscriptionId=$(az account show --query id -o tsv)
az ad sp create-for-rbac \
                        --name $servicePrincipalName\
                        --role contributor \
                        --scopes /subscriptions/$subscriptionId \
                        --sdk-auth
                            
  # The command should output a JSON object similar to this:
 
  {
    "clientId": "<GUID>",
    "clientSecret": "<STRING>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    "resourceManagerEndpointUrl": "<URL>"
    (...)
  }
```

- Then, assign the "User Access Administrator" role to the service principal created
  
```bash
servicePrincipalId = $(az ad sp list --display-name "$servicePrincipalName" --query "[].id" -o tsv)
az role assignment create --assignee $servicePrincipalId \
                          --role "User Access Administrator" \
                          --scopes /subscriptions/$subscriptionId
```
