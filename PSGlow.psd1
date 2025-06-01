@{
    # Script module or binary module file associated with this manifest.
    RootModule           = 'PSGlow.psm1'
    
    # Version number of this module.
    ModuleVersion        = '1.0.0'
    
    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')
    
    # ID used to uniquely identify this module
    GUID                 = '3ce5784d-90ac-438a-9cf1-f33d97363466'
    
    # Author of this module
    Author               = 'Doug Finke'
    
    # Company or vendor of this module
    CompanyName          = 'Doug Finke'
    
    # Copyright statement for this module
    Copyright            = '(c) 2025 Doug Finke. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description          = 'Terminal Markdown Renderer for PowerShell - renders Markdown to the terminal with ANSI formatting'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '7.0'
    
    # Functions to export from this module
    FunctionsToExport    = @(
        # 'Calculate-ColumnWidths'
        # 'Format-CodeBlockLine'
        # 'Format-InlineMarkdown'
        # 'Format-MarkdownLine'
        'Invoke-PSGlow'
        # 'Parse-TableAlignment'
        # 'Render-Markdown'
        # 'Render-Table'
        # 'Render-TableRow'
        # 'Split-TableCells'
        # 'Test-TableLine'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport      = @()
    
    # Variables to export from this module
    VariablesToExport    = @()
    
    # Aliases to export from this module
    AliasesToExport      = @('psglow')
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData          = @{
        PSData = @{
            # Tags applied to this module
            Tags         = @('Markdown', 'Terminal', 'ANSI', 'Rendering', 'Console')
            
            # A URL to the license for this module.
            LicenseUri   = ''
            
            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dfinke/psglow'
            
            # A URL to an icon representing this module.
            IconUri      = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of PSGlow - Terminal Markdown Renderer for PowerShell'
        }
    }
}