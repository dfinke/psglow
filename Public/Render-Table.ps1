function Render-Table {
    <#
    .SYNOPSIS
    Renders a markdown table with proper formatting and borders.
    
    .DESCRIPTION
    Takes an array of table lines and renders them as a formatted table
    with borders, proper alignment, and header formatting. Validates that
    the input represents a proper markdown table before rendering.
    
    .PARAMETER TableLines
    Array of table lines including header, divider, and data rows.
    
    .EXAMPLE
    $lines = @("| Name | Age |", "|------|-----|", "| John | 30 |")
    Render-Table $lines
    Renders a formatted table with borders and proper alignment.
    #>
    param([array]$TableLines)
    
    if ($TableLines.Count -lt 2) {
        # Not a valid table, render as regular lines
        foreach ($line in $TableLines) {
            Write-Host $line
        }
        return
    }
    
    # Check if second line is a divider
    $dividerPattern = '^\|[-:\s|]+\|$'
    if ($TableLines[1].Trim() -notmatch $dividerPattern) {
        # Not a valid table, render as regular lines
        foreach ($line in $TableLines) {
            Write-Host $line
        }
        return
    }
    
    # Parse table structure
    $headerLine = $TableLines[0]
    $dividerLine = $TableLines[1]
    $dataLines = $TableLines[2..($TableLines.Count - 1)]
    
    # Get alignment information
    $alignments = Parse-TableAlignment $dividerLine
    
    # Calculate column widths
    $allRows = @($headerLine) + $dataLines
    $columnWidths = Calculate-ColumnWidths $allRows
    
    # Render top border
    $topBorderParts = @()
    for ($i = 0; $i -lt $columnWidths.Count; $i++) {
        $width = $columnWidths[$i]
        $topBorderParts += "─" * $width
    }
    $topBorder = "┌" + ($topBorderParts -join "┬") + "┐"
    Write-Host $topBorder
    
    # Render header
    $headerCells = Split-TableCells $headerLine
    $renderedHeader = Render-TableRow $headerCells $columnWidths $alignments $true
    Write-Host $renderedHeader
    
    # Render middle border (separator between header and data)
    $middleBorderParts = @()
    for ($i = 0; $i -lt $columnWidths.Count; $i++) {
        $width = $columnWidths[$i]
        $middleBorderParts += "─" * $width
    }
    $middleBorder = "├" + ($middleBorderParts -join "┼") + "┤"
    Write-Host $middleBorder
    
    # Render data rows
    foreach ($dataLine in $dataLines) {
        $dataCells = Split-TableCells $dataLine
        $renderedRow = Render-TableRow $dataCells $columnWidths $alignments $false
        Write-Host $renderedRow
    }
    
    # Render bottom border
    $bottomBorderParts = @()
    for ($i = 0; $i -lt $columnWidths.Count; $i++) {
        $width = $columnWidths[$i]
        $bottomBorderParts += "─" * $width
    }
    $bottomBorder = "└" + ($bottomBorderParts -join "┴") + "┘"
    Write-Host $bottomBorder
}