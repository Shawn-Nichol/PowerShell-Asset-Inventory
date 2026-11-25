# Tracked applications (public list - committed to the repository)
#
# Applications that should not be published, such as security tools, go in
# the Applications section of Local\Settings.psd1 instead.
# See Config\Settings.example.psd1.
#
# Each entry describes one application to look for in the installed programs list.
#
#   Name           Display name for the application (required)
#   Match          Wildcard pattern(s) matched against the installed program name.
#                  Defaults to '*<Name>*' when omitted.
#   Functionality  What the application does
#   UserType       End User / Server / Service classification
#   ServiceType    Service or Application (defaults to Application)
#   Executable     Known executable, used when it cannot be discovered
#
# Entries are checked in order and the first match wins, so put more specific
# patterns (for example 'GV Stratus') before general ones.
# Applications without a Functionality are reported with the note
# "Application definition required".

@{
    Applications = @(
        @{
            Name          = 'Burli'
            Functionality = 'News Content Software'
            UserType      = 'End User'
            ServiceType   = 'Application'
            Executable    = 'Burli.exe'
        }
        @{
            Name          = 'iMediaLogger'
            Match         = @('*iMedia*')
            Functionality = 'Audio Logger'
            UserType      = 'Service - Content Capture'
            ServiceType   = 'Application'
        }
        @{
            Name          = 'CSRDS'
            Functionality = 'Metadata Transfer'
            UserType      = 'Service - Content Transfer'
            ServiceType   = 'Application'
        }
        @{
            Name          = 'Dav'
            Match         = @('Dav*')
            Functionality = 'Site Monitor Interface'
            UserType      = 'End User'
            ServiceType   = 'Application'
        }
        @{
            Name          = 'GV Stratus'
            Match         = @('*GV Stratus*', '*Stratus*')
            Functionality = 'News Production System'
            UserType      = 'End User'
            ServiceType   = 'Application'
            Executable    = 'STRATUS.exe'
        }
        @{
            Name          = 'OpenMedia'
            Functionality = 'News Production System'
            UserType      = 'End User'
            ServiceType   = 'Application'
            Executable    = 'OpenMedia.exe'
        }
        @{
            Name          = 'VoxPro'
            Functionality = 'Audio Editor - Phone Callers'
            UserType      = 'End User'
            ServiceType   = 'Application'
        }
        @{
            Name          = 'TeamViewer'
            Functionality = 'Remote Access'
            UserType      = 'End User'
            ServiceType   = 'Application'
            Executable    = 'TeamViewer.exe'
        }

        # Tracked, but not yet described
        @{ Name = 'WideOrbit' }
        @{ Name = 'DJB' }
        @{ Name = 'Arctic Palm' }
        @{ Name = 'Nautel' }
        @{ Name = 'Sage'; Match = @('Sage*') }
        @{ Name = 'vMix' }
        @{ Name = 'Pro Tools'; Match = @('*Pro Tools*', '*ProTools*') }
        @{ Name = 'LeanEncoder' }
        @{ Name = 'DreamEncoder' }
    )
}
