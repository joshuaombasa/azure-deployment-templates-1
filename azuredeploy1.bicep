param location string = resourceGroup().location
param adminUsername string
@secure() 
param adminPassword string // Declare adminPassword as secure
param vmName string
param vmSize string = 'Standard_DS1_v2'

// Define the Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Define the Public IP Address
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${vmName}-ip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Define the Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
    name: '${vmName}-nic'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            subnet: {
              id: '${vnet.id}/subnets/default' // Use the correct reference for the subnet
            }
            publicIPAddress: {
              id: publicIpAddress.id
            }
          }
        }
      ]
    }
  }
  

// Define the Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword // This will now be secure
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
