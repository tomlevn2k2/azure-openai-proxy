param privateDnsZoneName string
param vnetId string
param vnetName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

output id string = privateDnsZone.id
output name string = privateDnsZone.name
