function Format-CodeBlockLine {
    <#
    .SYNOPSIS
    Formats a line within a code block with appropriate syntax highlighting.
    
    .DESCRIPTION
    Applies formatting to a line within a code block, including PowerShell-specific
    syntax highlighting for PowerShell code blocks and general dim formatting
    for other languages.
    
    .PARAMETER Line
    The line of code to format.
    
    .PARAMETER Language
    The programming language of the code block (optional).
    
    .EXAMPLE
    Format-CodeBlockLine "Get-Process | Where-Object Name -eq 'pwsh'" "powershell"
    Returns the PowerShell code with cmdlet highlighting and parameter formatting.
    
    .EXAMPLE
    Format-CodeBlockLine "console.log('Hello World');" "javascript"
    Returns the JavaScript code with basic dim formatting.
    #>
    param([string]$Line, [string]$Language = "")
    
    # Apply indentation first
    $result = "  "
    
    # Only apply PowerShell syntax highlighting for PowerShell code blocks
    if ($Language -eq "powershell" -or $Language -eq "ps1") {
        # Apply PowerShell syntax highlighting
        $processedLine = $Line
        
        # Highlight PowerShell cmdlets (Get-*, Set-*, New-*, etc.)
        $processedLine = $processedLine -replace '\b([A-Z][a-z]*-[A-Za-z]+)\b', "$($script:AnsiCodes.Magenta)`$1$($script:AnsiCodes.Reset)"
        
        # Highlight pipes
        $processedLine = $processedLine -replace '\|', "$($script:AnsiCodes.Yellow)|$($script:AnsiCodes.Reset)"
        
        # Highlight parameters (-ParameterName)
        $processedLine = $processedLine -replace '\s(-[A-Za-z]+)\b', " $($script:AnsiCodes.Salmon)`$1$($script:AnsiCodes.Reset)"
        
        # Apply dim color to unprocessed text and preserve all whitespace
        $result += "$($script:AnsiCodes.Dim)$processedLine$($script:AnsiCodes.Reset)"
    } else {
        # For non-PowerShell code blocks, just apply dim formatting
        $result += "$($script:AnsiCodes.Dim)$Line$($script:AnsiCodes.Reset)"
    }
    
    return $result
}