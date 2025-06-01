function Test-TableLine {
    <#
    .SYNOPSIS
    Tests if a line is part of a markdown table.
    
    .DESCRIPTION
    Checks if a line appears to be part of a markdown table by looking for
    table row patterns (lines that start and end with |) or divider patterns.
    
    .PARAMETER Line
    The line of text to test.
    
    .EXAMPLE
    Test-TableLine "| Name | Age |"
    Returns $true because this looks like a table row.
    
    .EXAMPLE
    Test-TableLine "|------|-----|"
    Returns $true because this looks like a table divider.
    
    .EXAMPLE
    Test-TableLine "Regular text"
    Returns $false because this is not a table line.
    #>
    param([string]$Line)
    
    # Check if line looks like a table row (starts and ends with |, or is a divider)
    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $false
    }
    
    $trimmed = $Line.Trim()
    return $trimmed -match '^\|.*\|$' -or $trimmed -match '^\|[-:\s|]+\|$'
}