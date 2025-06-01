function Parse-TableAlignment {
    <#
    .SYNOPSIS
    Parses table column alignment information from a markdown table divider line.
    
    .DESCRIPTION
    Analyzes the divider line of a markdown table to determine the alignment
    for each column based on the presence and position of colons.
    
    .PARAMETER DividerLine
    The table divider line containing alignment markers (e.g., "|:--:|--:|").
    
    .EXAMPLE
    Parse-TableAlignment "|:--:|--:|-----|"
    Returns @('center', 'right', 'left') based on the colon positions.
    
    .EXAMPLE
    Parse-TableAlignment "|-----|-----|"
    Returns @('left', 'left') as the default alignment.
    #>
    param([string]$DividerLine)
    
    $alignments = @()
    $cells = Split-TableCells $DividerLine
    
    foreach ($cell in $cells) {
        $trimmed = $cell.Trim()
        if ($trimmed -match '^:.*:$') {
            $alignments += 'center'
        } elseif ($trimmed -match ':$') {
            $alignments += 'right'
        } else {
            $alignments += 'left'
        }
    }
    
    return $alignments
}