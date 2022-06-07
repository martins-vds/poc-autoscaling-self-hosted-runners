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

module vnet './modules/vnet.bicep' = {
  scope: rg
  name: 'vnetDeploy'
  params: {
    vnetName: '${resourcePrefix}-vnet-${clusterName}-${location}'
    subnetName: '${resourcePrefix}-snet-${clusterName}-${location}'
    vnetAddressPrefixes: [
      '10.0.0.0/8'
    ]
    subnetAddressPrefix: '10.240.0.0/16'
    location: location
  }
}

module aks './modules/aks.bicep' = {
  name: 'clusterDeploy'
  scope: rg
  params: {
    location: location
    clusterName: '${resourcePrefix}-${clusterName}-${take(uniqueString(rg.id),5)}'
    resourcePrefix: resourcePrefix
    adminGroupObjectIDs: adminGroupObjectIDs
    subnetId: vnet.outputs.subnetId
  }
}

module acr './modules/registry.bicep' = {
  scope: rg
  name: 'acrDeploy'
  params:{
    aksPrincipalId: aks.outputs.clusterPrincipalID
    location: location
    registryName: '${resourcePrefix}-acr'
  }
  dependsOn: [
    aks
  ]
}

output clusterName string = aks.outputs.clusterName