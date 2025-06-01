function Split-TableCells {
    <#
    .SYNOPSIS
    Splits a markdown table line into individual cell contents.
    
    .DESCRIPTION
    Takes a markdown table line and splits it into an array of cell contents,
    removing leading and trailing pipes and trimming whitespace from each cell.
    
    .PARAMETER Line
    The table line to split into cells (e.g., "| Name | Age | City |").
    
    .EXAMPLE
    Split-TableCells "| John | 30 | NYC |"
    Returns @('John', '30', 'NYC')
    
    .EXAMPLE
    Split-TableCells "|-----|:--:|----:|"
    Returns @('-----', ':--:', '----:')
    #>
    param([string]$Line)
    
    # Remove leading and trailing pipes, then split by |
    $content = $Line.Trim()
    if ($content.StartsWith('|')) {
        $content = $content.Substring(1)
    }
    if ($content.EndsWith('|')) {
        $content = $content.Substring(0, $content.Length - 1)
    }
    
    # Split by | (simple version - will add escape handling later if needed)
    $cells = $content -split '\|'
    
    # Process each cell to trim whitespace
    $processedCells = @()
    foreach ($cell in $cells) {
        $processedCells += $cell.Trim()
    }
    
    return $processedCells
}