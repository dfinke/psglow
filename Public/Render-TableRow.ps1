function Render-TableRow {
    <#
    .SYNOPSIS
    Renders a single table row with proper alignment and formatting.
    
    .DESCRIPTION
    Takes cell contents and renders them as a single table row with proper
    padding, alignment, and formatting. Applies header formatting when specified.
    
    .PARAMETER Cells
    Array of cell contents for the row.
    
    .PARAMETER ColumnWidths
    Array of column widths for proper padding.
    
    .PARAMETER Alignments
    Array of alignment specifications ('left', 'center', 'right') for each column.
    
    .PARAMETER IsHeader
    Boolean indicating if this row should be formatted as a header.
    
    .EXAMPLE
    Render-TableRow @('Name', 'Age') @(10, 5) @('left', 'right') $true
    Renders a header row with proper alignment and formatting.
    #>
    param(
        [array]$Cells,
        [array]$ColumnWidths,
        [array]$Alignments,
        [bool]$IsHeader
    )
    
    $renderedCells = @()
    
    for ($i = 0; $i -lt $Cells.Count; $i++) {
        $cell = $Cells[$i]
        $width = if ($i -lt $ColumnWidths.Count) { $ColumnWidths[$i] } else { $cell.Length }
        $alignment = if ($i -lt $Alignments.Count) { $Alignments[$i] } else { 'left' }
        
        # Process inline markdown in cell content
        $formattedCell = Format-InlineMarkdown $cell
        
        # Apply header formatting
        if ($IsHeader) {
            $formattedCell = "$($script:AnsiCodes.BrightWhite)$formattedCell$($script:AnsiCodes.Reset)"
        }
        
        # Calculate padding for alignment
        # Remove ANSI codes for length calculation
        $cleanCell = $formattedCell -replace '\x1b\[[0-9;]*m', ''
        $padding = [math]::Max(0, $width - $cleanCell.Length)
        
        $paddedCell = switch ($alignment) {
            'center' {
                $leftPad = [math]::Floor($padding / 2)
                $rightPad = $padding - $leftPad
                (" " * $leftPad) + $formattedCell + (" " * $rightPad)
            }
            'right' {
                (" " * $padding) + $formattedCell
            }
            default { # 'left'
                $formattedCell + (" " * $padding)
            }
        }
        
        $renderedCells += $paddedCell
    }
    
    return "│" + ($renderedCells -join "│") + "│"
}