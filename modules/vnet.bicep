param location string
param vnetName string
param vnetAddressPrefix string
param integrationSubnetName string
param integrationSubnetPrefix string
param privateEndpointSubnetName string
param privateEndpointSubnetPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource integrationSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: vnet
  name: integrationSubnetName
  properties: {
    addressPrefix: integrationSubnetPrefix
    delegations: [
      {
        name: 'appservice'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: vnet
  name: privateEndpointSubnetName
  properties: {
    addressPrefix: privateEndpointSubnetPrefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

output id string = vnet.id
output name string = vnet.name
output integrationSubnetId string = integrationSubnet.id
output privateEndpointSubnetId string = privateEndpointSubnet.id
