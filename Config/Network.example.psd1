# Network settings
# Copy this file to Network.psd1 and set the subnets for your environment.
# Network.psd1 is git-ignored so internal addressing is never committed.
# Values are wildcard patterns matched against IPv4 addresses (for example '10.20.*').
# Leave a value empty ('') to skip that check.

@{
    # Subnet of the main network adapter.
    # If empty, the adapter with a default gateway is used.
    PrimarySubnet    = '10.0.*'

    # Machines whose primary IP matches this subnet are reported as On-Air.
    # Everything else is reported as Office.
    OnAirSubnet      = '10.0.50.*'

    # Subnet of the Wheatstone audio network adapter.
    WheatstoneSubnet = '192.168.*'
}
