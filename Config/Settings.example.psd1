# Local settings
#
# Everything specific to your environment lives in one place:
#   1. Create a folder named Local next to Start-Inventory.ps1
#   2. Copy this file to Local\Settings.psd1 and edit it
#   3. Copy Config\Computers.example.txt to Local\Computers.txt and list your computers
#
# The whole Local folder is git-ignored, so nothing in it is ever committed.

@{
    # Computer list file, one hostname per line.
    # A file name is looked for in the Local folder; a full path can point anywhere.
    # Can also be overridden for one run with -ComputerListPath.
    ComputerList = 'Computers.txt'

    # Network subnets, as wildcard patterns matched against IPv4 addresses.
    # Leave a value empty ('') to skip that check.
    Network = @{
        # Main network adapter. If empty, the adapter with a default gateway is used.
        PrimarySubnet    = '10.0.*'

        # Machines whose main IP matches are reported as On-Air; all others as Office.
        OnAirSubnet      = '10.0.50.*'

        # Wheatstone audio network adapter.
        WheatstoneSubnet = '192.168.*'
    }

    # Applications that should not be published, such as security tools.
    # Same format as Config\Applications.psd1. These are checked first,
    # so they take priority when both lists would match the same program.
    Applications = @(
        @{
            Name          = 'Example Security Agent'
            Match         = @('*Example Security Agent*')
            Functionality = 'Endpoint Security'
            UserType      = 'Service - Security'
            ServiceType   = 'Service'
        }
    )
}
