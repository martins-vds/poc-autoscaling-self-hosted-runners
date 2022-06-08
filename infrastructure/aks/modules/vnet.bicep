param vnetName string
param subnetName string
param vnetAddressPrefixes array
param subnetAddressPrefix string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }      
    ]
  }
}

output subnetId string = '${vnet.id}/subnets/${subnetName}'
