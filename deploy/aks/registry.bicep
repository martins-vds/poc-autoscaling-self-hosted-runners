param registryName string
param aksPrincipalId string
param location string

@allowed([
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
])
param roleAcrPull string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource assignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, registryName, aksPrincipalId, 'AssignAcrPullToAks')
  scope: containerRegistry
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleAcrPull}'
  }
}

output name string = containerRegistry.name
