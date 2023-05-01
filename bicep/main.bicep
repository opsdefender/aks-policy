// Scope
targetScope = 'subscription'

// Parameters
@description('Specifies the location of the deployment.')
param location string

@description('List of policy definitions')
param policies array = [
  {
    name: 'AKS-CSI_Enable'
    definition: json(loadTextContent('../policy-definitions/AKS-CSI_Enable.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'ContainerAllowedCapabilities'
    definition: json(loadTextContent('../policy-definitions/ContainerAllowedCapabilitie.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'ContainerNoPriviledge'
    definition: json(loadTextContent('../policy-definitions/ContainerNoPriviledge.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
  {
    name: 'LoadbalancerNoPublicIPs'
    definition: json(loadTextContent('../policy-definitions/LoadbalancerNoPublicIPs.json'))
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    identity: false
  }
]

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = [for policy in policies: {
  name: guid(policy.name)
  properties: {
    description: policy.definition.properties.description
    displayName: policy.definition.properties.displayName
    metadata: policy.definition.properties.metadata
    mode: policy.definition.properties.mode
    parameters: policy.definition.properties.parameters
    policyType: policy.definition.properties.policyType
    policyRule: policy.definition.properties.policyRule
  }
}]

module policyAssignment './assignment.bicep' = [for (policy, i) in policies: {
  name: 'poAssign_${take(policy.name, 40)}'
  params: {
    policy: policy
    location: location
    policyDefinitionId: policyDefinition[i].id
  }
  dependsOn: [
    policyDefinition
  ]
}]
