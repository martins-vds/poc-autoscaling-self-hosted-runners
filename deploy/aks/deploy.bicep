targetScope = 'subscription'

param location string = deployment().location
param resourcePrefix string
param resourceGroupName string
param clusterName string
param adminGroupObjectIDs array

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module aks './aks.bicep' = {
  name: clusterName
  scope: rg
  params: {
    location: location
    clusterName: '${resourcePrefix}-${clusterName}-${take(uniqueString(rg.id),5)}'
    resourcePrefix: resourcePrefix
    vnetName: 'vnet-${take(uniqueString(rg.id),5)}'
    adminGroupObjectIDs: adminGroupObjectIDs
  }
}

module acr 'registry.bicep' = {
  scope: rg
  name: 'acr'
  params:{
    aksPrincipalId: aks.outputs.clusterPrincipalID
    location: location
    registryName: '${resourcePrefix}-acr'
  }
  dependsOn: [
    aks
  ]
}
