# Private tracked applications
#
# Copy this file to Applications.local.psd1 and add applications that should
# not be published, such as security or endpoint management tools.
# Applications.local.psd1 is git-ignored, so its contents are never committed.
#
# Same format as Applications.psd1. Entries here are checked before the public
# list, so they take priority when both would match the same program.
# The example below is a placeholder - replace it with your own entries.

@{
    Applications = @(
        @{
            Name          = 'Example Security Agent'
            Match         = @('*Example Security Agent*', '*Example Agent (legacy name)*')
            Functionality = 'Endpoint Security'
            UserType      = 'Service - Security'
            ServiceType   = 'Service'
        }
    )
}
