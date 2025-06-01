function Render-Markdown {
    <#
    .SYNOPSIS
    Renders markdown content to the terminal with ANSI formatting.
    
    .DESCRIPTION
    Takes markdown content and renders it to the terminal with proper ANSI
    formatting including support for headings, lists, code blocks, tables,
    and inline formatting. Handles complex structures like nested formatting
    and multi-line elements.
    
    .PARAMETER Content
    The markdown content to render.
    
    .EXAMPLE
    Render-Markdown "# Title`n`nThis is **bold** text."
    Renders the markdown with proper heading and bold formatting.
    
    .EXAMPLE
    Get-Content README.md -Raw | Render-Markdown
    Renders the content of a markdown file.
    #>
    param([string]$Content)
    
    if ([string]::IsNullOrWhiteSpace($Content)) {
        return
    }
    
    # Split content into lines for processing
    $lines = $Content -split "`n"
    
    $inCodeBlock = $false
    $codeFenceMarker = ""
    $codeBlockLanguage = ""
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
                $codeBlockLanguage = $language
                
                # Optionally show language label
                if (-not [string]::IsNullOrWhiteSpace($language)) {
                    Write-Host "  $($script:AnsiCodes.Dim)# $language$($script:AnsiCodes.Reset)"
                }
            } elseif ($fenceMarker -eq $codeFenceMarker) {
                # Ending the current code block
                $inCodeBlock = $false
                $codeFenceMarker = ""
                $codeBlockLanguage = ""
            } else {
                # Different fence marker inside code block - treat as content
                $renderedLine = Format-CodeBlockLine $line $codeBlockLanguage
                Write-Host $renderedLine
            }
        } elseif ($inCodeBlock) {
            # Inside code block - format as code
            $renderedLine = Format-CodeBlockLine $line $codeBlockLanguage
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