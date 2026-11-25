# =====================================================
# APPLICATION DEFINITIONS
# =====================================================


$ApplicationDefinitions = @{

    "iMediaLogger" = @{
        Functionality = "Audio Logger"
        UserType      = "Service - Content Capture"
        ServiceType   = "Application"
    }

    "Burli" = @{
        Functionality = "News Content Software"
        UserType      = "End User"
        ServiceType   = "Application"
    }

    "CSRDS" = @{
        Functionality = "Metadata Transfer"
        UserType      = "Service - Content Transfer"
        ServiceType   = "Application"
    }

    "Dav" = @{
        Functionality = "Site Monitor Interface"
        UserType      = "End User"
        ServiceType   = "Application"
    }

    "GV Stratus" = @{
        Functionality = "News Production System"
        UserType      = "End User"
        ServiceType   = "Application"
        Executable    = "STRATUS.exe"
    }

    "OpenMedia" = @{
        Functionality = "News Production System"
        UserType      = "End User"
        ServiceType   = "Application"
        Executable    = "OpenMedia.exe"
    }

    "VoxPro" = @{
        Functionality = "Audio Editor - Phone Callers"
        UserType      = "End User"
        ServiceType   = "Application"
    }
}