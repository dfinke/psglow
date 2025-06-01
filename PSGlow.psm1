# PSGlow - Terminal Markdown Renderer for PowerShell
# Author: Doug Finke (c) 2025

# ANSI escape codes for formatting
$script:AnsiCodes = @{
    Reset = "`e[0m"
    Bold = "`e[1m"
    Dim = "`e[2m"
    Italic = "`e[3m"
    Underline = "`e[4m"
    
    # Colors
    Black = "`e[30m"
    Red = "`e[31m"
    Green = "`e[32m"
    Yellow = "`e[33m"
    Blue = "`e[34m"
    Magenta = "`e[35m"
    Cyan = "`e[36m"
    White = "`e[37m"
    
    # Bright colors
    BrightBlack = "`e[90m"
    BrightRed = "`e[91m"
    BrightGreen = "`e[92m"
    BrightYellow = "`e[93m"
    BrightBlue = "`e[94m"
    BrightMagenta = "`e[95m"
    BrightCyan = "`e[96m"
    BrightWhite = "`e[97m"
    
    # Background colors
    BgDarkRed = "`e[48;5;52m"
    
    # Salmon/coral color for parameters
    Salmon = "`e[38;5;210m"
}

# Get all public function files
$PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue

# Dot source all public functions
foreach ($function in $PublicFunctions) {
    try {
        . $function.FullName
    }
    catch {
        Write-Error "Failed to import function $($function.Name): $_"
    }
}

# Create aliases for backward compatibility
Set-Alias -Name 'psglow' -Value 'Invoke-PSGlow'

# Export public functions and aliases
Export-ModuleMember -Function @(
    'Calculate-ColumnWidths'
    'Format-CodeBlockLine'
    'Format-InlineMarkdown'
    'Format-MarkdownLine'
    'Invoke-PSGlow'
    'Parse-TableAlignment'
    'Render-Markdown'
    'Render-Table'
    'Render-TableRow'
    'Split-TableCells'
    'Test-TableLine'
) -Alias @('psglow')