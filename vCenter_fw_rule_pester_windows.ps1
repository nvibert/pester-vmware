#Requires -Modules "Pester"
$correct_mgw_rule_name = "vCenter Inbound Rule"
$correct_mgw_rule_name_destination = "vCenter"
$correct_mgw_rule_port = "HTTPS"
$correct_network_segment_name = "odyssey-network"
$correct_network_range = "192.168.20.0/24"
$correct_network_gateway = "192.168.20.1/24"
$correct_type = "ROUTED"
$correct_dhcp_range = "192.168.20.2-192.168.20.40"

$org_id = ""
$sddc_id = ""
$OrgName = “”
$SDDCName = “”

$RefreshToken = ""

Install-Module -Name VMware.VMC
Install-Module -Name VMware.VMC.NSXT
Connect-VmcServer -RefreshToken $RefreshToken
Connect-NSXTProxy -RefreshToken $RefreshToken -OrgName $OrgName -SDDCName $SDDCName


#
#   the Describe block contains all the tests needed to verify the task is complete 
#   see https://pester.dev/docs/commands/Describe
#
Describe "The MGW Rule" {

    $vcenterMGWRule = Get-NSXTFirewall -GatewayType MGW -Name $correct_mgw_rule_name
    $vCenterMGWRuleDestination = $vCenterMGWRule.Destination 
    $vCenterMGWRulePort = $vCenterMGWRule.Services
    $new_network = Get-NSXTSegment -Name "odyssey-network"
    $new_network_range = $new_network.Network
    $new_network_gateway = $new_network.Gateway
    $new_network_type = $new_network.TYPE
    $new_network_dhcp_range = $new_network.DHCPRange

    #
    #   each It block contains a test assertion
    #   see https://pester.dev/docs/commands/It
    #
    It "exists" {
        #
        #   an assertion uses the Should command and has many options
        #   see https://pester.dev/docs/usage/assertions
        #
        $vcenterMGWRule = Get-NSXTFirewall -GatewayType MGW -Name $correct_mgw_rule_name
        $vcenterMGWRule | Should -Not -BeNullOrEmpty
    }

    It "has vCenter as the destination" {
        $vcenterMGWRule = Get-NSXTFirewall -GatewayType MGW -Name $correct_mgw_rule_name
        $vCenterMGWRuleDestination = $vCenterMGWRule.Destination 
        $vCenterMGWRuleDestination | Should -Be $correct_mgw_rule_name_destination
    }

    It "has HTTPS as the destination" {
        $vcenterMGWRule = Get-NSXTFirewall -GatewayType MGW -Name $correct_mgw_rule_name
        $vCenterMGWRulePort = $vCenterMGWRule.Services
        $correct_mgw_rule_port | Should -BeIn $vCenterMGWRulePort
    }

    It "has ALLOW as the action" {
        $vcenterMGWRule = Get-NSXTFirewall -GatewayType MGW -Name $correct_mgw_rule_name
        $vCenterMGWRule.Action | Should -Be "ALLOW"
    }

    It "has a correct network configured, with the correct network mask" {
        $new_network.Name | Should -Be $correct_network_segment_name
    }

    It "has a correct network range configured." {
        $new_network_range | Should -Be $correct_network_range
    }

    It "has a correct network gateway configured." {
        $new_network_gateway | Should -Be $correct_network_gateway
    }

    It "has a correct network type." {
        $new_network_type | Should -Be $correct_type
    }

    It "has a correct DHCP range configured." {
        $new_network_dhcp_range | Should -Be $correct_dhcp_range
    }

}
