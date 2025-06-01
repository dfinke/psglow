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

function Render-Markdown {
    param([string]$Content)
    
    if ([string]::IsNullOrWhiteSpace($Content)) {
        return
    }
    
    # Split content into lines for processing
    $lines = $Content -split "`n"
    
    foreach ($line in $lines) {
        $renderedLine = Format-MarkdownLine $line
        Write-Host $renderedLine
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

function Format-InlineMarkdown {
    param([string]$Text)
    
    $result = $Text
    
    # Process links [text](url) first
    $result = $result -replace '\[([^\]]+)\]\(([^)]+)\)', "$($script:AnsiCodes.Blue)$($script:AnsiCodes.Underline)`$1$($script:AnsiCodes.Reset) ($($script:AnsiCodes.Dim)`$2$($script:AnsiCodes.Reset))"
    
    # Process bold **text** (including cases with nested italic)
    # This handles **text**, **text with *italic* inside**
    while ($result -match '\*\*([^*]+(?:\*[^*]+\*[^*]*)*)\*\*') {
        $boldText = $matches[1]
        # Process italic within the bold text
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
        # Handle piped input by reading all input
        $stdinContent = @()
        
        # Read from stdin if available
        if ([Console]::IsInputRedirected) {
            $reader = [System.IO.StreamReader]::new([Console]::OpenStandardInput())
            $content = $reader.ReadToEnd()
            $reader.Close()
            
            if (-not [string]::IsNullOrWhiteSpace($content)) {
                Render-Markdown $content
            } else {
                Write-Error "No input content received"
            }
        } else {
            Write-Error "No input provided. Use: psglow <file> or pipe content to psglow"
        }
    }
}
catch {
    Write-Error "Error processing Markdown: $_"
}