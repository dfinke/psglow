#!/usr/bin/env pwsh
<#
.SYNOPSIS
    psglow - Terminal Markdown Renderer for PowerShell

.DESCRIPTION
    A PowerShell script that renders Markdown to the terminal with ANSI formatting.

.EXAMPLE
    psglow README.md
    Renders the README.md file

.EXAMPLE
    "## Heading" | psglow
    Renders piped Markdown content
#>

param(
    [Parameter(Position = 0)]
    [string]$Path
)

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
}

function Test-TableLine {
    param([string]$Line)
    
    # Check if line looks like a table row (starts and ends with |, or is a divider)
    if ([string]::IsNullOrWhiteSpace($Line)) {
        return $false
    }
    
    $trimmed = $Line.Trim()
    return $trimmed -match '^\|.*\|$' -or $trimmed -match '^\|[-:\s|]+\|$'
}

function Parse-TableAlignment {
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

function Split-TableCells {
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

function Calculate-ColumnWidths {
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

function Render-Table {
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
    
    # Render header
    $headerCells = Split-TableCells $headerLine
    $renderedHeader = Render-TableRow $headerCells $columnWidths $alignments $true
    Write-Host $renderedHeader
    
    # Render divider
    $dividerParts = @()
    for ($i = 0; $i -lt $columnWidths.Count; $i++) {
        $width = $columnWidths[$i]
        $dividerParts += "-" * $width
    }
    $renderedDivider = $dividerParts -join "|"
    Write-Host $renderedDivider
    
    # Render data rows
    foreach ($dataLine in $dataLines) {
        $dataCells = Split-TableCells $dataLine
        $renderedRow = Render-TableRow $dataCells $columnWidths $alignments $false
        Write-Host $renderedRow
    }
}

function Render-TableRow {
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
            $formattedCell = "$($script:AnsiCodes.Cyan)$($script:AnsiCodes.Bold)$formattedCell$($script:AnsiCodes.Reset)"
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
    
    return $renderedCells -join "|"
}

function Render-Markdown {
    param([string]$Content)
    
    if ([string]::IsNullOrWhiteSpace($Content)) {
        return
    }
    
    # Split content into lines for processing
    $lines = $Content -split "`n"
    
    $inCodeBlock = $false
    $codeFenceMarker = ""
    $inTable = $false
    $tableLines = @()
    
    foreach ($line in $lines) {
        # Check for code fence start/end
        if ($line -match '^(```|~~~)(.*)$') {
            $fenceMarker = $matches[1]
            $language = $matches[2].Trim()
            
            if (-not $inCodeBlock) {
                # Starting a code block
                $inCodeBlock = $true
                $codeFenceMarker = $fenceMarker
                
                # Optionally show language label
                if (-not [string]::IsNullOrWhiteSpace($language)) {
                    Write-Host "  $($script:AnsiCodes.Dim)# $language$($script:AnsiCodes.Reset)"
                }
            } elseif ($fenceMarker -eq $codeFenceMarker) {
                # Ending the current code block
                $inCodeBlock = $false
                $codeFenceMarker = ""
            } else {
                # Different fence marker inside code block - treat as content
                $renderedLine = Format-CodeBlockLine $line
                Write-Host $renderedLine
            }
        } elseif ($inCodeBlock) {
            # Inside code block - format as code
            $renderedLine = Format-CodeBlockLine $line
            Write-Host $renderedLine
        } elseif (Test-TableLine $line) {
            # Table line detected
            if (-not $inTable) {
                $inTable = $true
                $tableLines = @()
            }
            $tableLines += $line
        } else {
            # Check if we were in a table and need to render it
            if ($inTable) {
                Render-Table $tableLines
                $inTable = $false
                $tableLines = @()
            }
            
            # Regular markdown processing
            $renderedLine = Format-MarkdownLine $line
            Write-Host $renderedLine
        }
    }
    
    # Handle table at end of input
    if ($inTable) {
        Render-Table $tableLines
    }
}

function Format-MarkdownLine {
    param([string]$Line)
    
    # Skip empty lines
    if ([string]::IsNullOrWhiteSpace($Line)) {
        return ""
    }
    
    $formattedLine = $Line
    
    # Process headings first (they take precedence)
    if ($Line -match '^(#{1,6})\s+(.+)$') {
        $level = $matches[1].Length
        $text = $matches[2]
        $indent = "  " * ($level - 1)
        return "$indent$($script:AnsiCodes.Cyan)$($script:AnsiCodes.Bold)$text$($script:AnsiCodes.Reset)"
    }
    
    # Process bullet lists
    if ($Line -match '^\s*[-*+]\s+(.+)$') {
        $text = $matches[1]
        $processedText = Format-InlineMarkdown $text
        return "  $($script:AnsiCodes.Yellow)•$($script:AnsiCodes.Reset) $processedText"
    }
    
    # Process ordered lists
    if ($Line -match '^\s*\d+\.\s+(.+)$') {
        $text = $matches[1]
        $processedText = Format-InlineMarkdown $text
        return "  $processedText"
    }
    
    # Process inline formatting for regular text
    return Format-InlineMarkdown $formattedLine
}

function Format-CodeBlockLine {
    param([string]$Line)
    
    # Apply indentation and dim color to code block content
    # Preserve all whitespace and don't process any markdown
    return "  $($script:AnsiCodes.Dim)$Line$($script:AnsiCodes.Reset)"
}

function Format-InlineMarkdown {
    param([string]$Text)
    
    $result = $Text
    
    # Process links [text](url) first
    $result = $result -replace '\[([^\]]+)\]\(([^)]+)\)', "$($script:AnsiCodes.Blue)$($script:AnsiCodes.Underline)`$1$($script:AnsiCodes.Reset) ($($script:AnsiCodes.Dim)`$2$($script:AnsiCodes.Reset))"
    
    # Process bold **text** (including cases with nested italic)
    while ($result -match '\*\*([^*]+(?:\*[^*]+\*[^*]*)*)\*\*') {
        $boldText = $matches[1]
        # Process italic within the bold text, ensuring proper reset codes
        $processedBoldText = $boldText -replace '\*([^*]+)\*', "$($script:AnsiCodes.Italic)`$1$($script:AnsiCodes.Reset)$($script:AnsiCodes.Bold)"
        $result = $result -replace [regex]::Escape("**$boldText**"), "$($script:AnsiCodes.Bold)$processedBoldText$($script:AnsiCodes.Reset)"
    }
    
    # Process remaining italic *text* (standalone italic)
    $result = $result -replace '(?<!\*)\*([^*]+)\*(?!\*)', "$($script:AnsiCodes.Italic)`$1$($script:AnsiCodes.Reset)"
    
    return $result
}

# Main script execution
try {
    # Handle file input
    if ($Path) {
        if (Test-Path $Path) {
            $content = Get-Content -Path $Path -Raw
            Render-Markdown $content
        } else {
            Write-Error "File not found: $Path"
        }
    } else {
        # Handle piped input
        try {
            $reader = [System.IO.StreamReader]::new([Console]::OpenStandardInput())
            $content = $reader.ReadToEnd()
            $reader.Close()
            
            if (-not [string]::IsNullOrWhiteSpace($content)) {
                Render-Markdown $content
            } else {
                Write-Error "No input provided. Use: psglow <file> or pipe content to psglow"
            }
        }
        catch {
            Write-Error "No input provided. Use: psglow <file> or pipe content to psglow"
        }
    }
}
catch {
    Write-Error "Error processing Markdown: $_"
}