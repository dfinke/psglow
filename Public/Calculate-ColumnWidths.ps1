function Calculate-ColumnWidths {
    <#
    .SYNOPSIS
    Calculates the maximum width needed for each column in a table.
    
    .DESCRIPTION
    Analyzes all rows in a table to determine the maximum content width
    for each column, accounting for ANSI escape codes that don't affect
    display width.
    
    .PARAMETER TableRows
    Array of table row strings to analyze for column widths.
    
    .EXAMPLE
    Calculate-ColumnWidths @("| Name | Age |", "| John Smith | 30 |")
    Returns @(10, 3) representing the maximum width for each column.
    #>
    param([array]$TableRows)
    
    $maxWidths = @()
    
    foreach ($row in $TableRows) {
        $cells = Split-TableCells $row
        for ($i = 0; $i -lt $cells.Count; $i++) {
            # Remove ANSI codes for width calculation
            $cleanCell = $cells[$i] -replace '\x1b\[[0-9;]*m', ''
            $width = $cleanCell.Length
            
            if ($i -ge $maxWidths.Count) {
                $maxWidths += $width
            } elseif ($width -gt $maxWidths[$i]) {
                $maxWidths[$i] = $width
            }
        }
    }
    
    return $maxWidths
}