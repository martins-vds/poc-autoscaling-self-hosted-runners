param adminGroupObjectIDs array
param resourcePrefix string
param clusterName string
param subnetId string
param nodeAdminUsername string = 'azureadmin'
@secure()
param nodeAdminPassword string
param location string

var uniqueClusterName = '${clusterName}-${take(uniqueString(resourceGroup().id),5)}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${resourcePrefix}-oms-${clusterName}-${location}'
  location: location
  properties: {
    sku: {
      name: 'Standalone'
    }
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2022-03-02-preview' = {
  name: uniqueClusterName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.22.6'
    dnsPrefix: '${uniqueClusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'lnpool'
        count: 1
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: subnetId
        maxPods: 110
        type: 'VirtualMachineScaleSets'
        maxCount: 2
        minCount: 1
        enableAutoScaling: true
        powerState: {
          code: 'Running'
        }
        currentOrchestratorVersion: '1.22.6'
        enableNodePublicIP: false
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        enableFIPS: false
      }
      {
        name: 'wnpool'
        count: 1
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: subnetId
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        maxCount: 2
        minCount: 1
        enableAutoScaling: true
        powerState: {
          code: 'Running'
        }
        currentOrchestratorVersion: '1.22.6'
        enableNodePublicIP: false
        mode: 'User'
        osType: 'Windows'
        enableFIPS: false
        nodeTaints: [
          'node.kubernetes.io/os=Windows:NoSchedule'
        ]
      }
    ]
    windowsProfile: {
      adminUsername: nodeAdminUsername
      adminPassword: nodeAdminPassword
      enableCSIProxy: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
      httpApplicationRouting: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }
    }
    nodeResourceGroup: 'poc-${resourcePrefix}-aks-nodes-${uniqueClusterName}-${location}'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'      
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      outboundType: 'loadBalancer'
    }
    aadProfile: !empty(adminGroupObjectIDs) ? {
      managed: true
      adminGroupObjectIDs: adminGroupObjectIDs
    } : null
  }
}

resource linuxAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2022-03-02-preview' = {
  parent: aks
  name: 'lnpool'
  properties: {
    count: 1
    vmSize: 'Standard_B4ms'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    vnetSubnetID: subnetId
    maxPods: 110
    type: 'VirtualMachineScaleSets'
    maxCount: 2
    minCount: 1
    enableAutoScaling: true
    powerState: {
      code: 'Running'
    }
    currentOrchestratorVersion: '1.22.6'
    enableNodePublicIP: false
    mode: 'System'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    enableFIPS: false
  }
}

resource windowsAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2022-03-02-preview' = {
  parent: aks
  name: 'wnpool'
  properties: {
    count: 1
    vmSize: 'Standard_B4ms'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    vnetSubnetID: subnetId
    maxPods: 30
    type: 'VirtualMachineScaleSets'
    maxCount: 2
    minCount: 1
    enableAutoScaling: true
    powerState: {
      code: 'Running'
    }
    currentOrchestratorVersion: '1.22.6'
    enableNodePublicIP: false
    mode: 'User'
    osType: 'Windows'
    enableFIPS: false
    nodeTaints: [
      'node.kubernetes.io/os=Windows:NoSchedule'
    ]
  }
}

output clusterName string = aks.name
output clusterPrincipalID string = aks.properties.identityProfile.kubeletidentity.objectId
