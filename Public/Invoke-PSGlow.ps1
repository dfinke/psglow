function Invoke-PSGlow {
    <#
    .SYNOPSIS
    Main entry point for the PSGlow markdown renderer.
    
    .DESCRIPTION
    Renders markdown content to the terminal with ANSI formatting. Can process
    files or piped input. This is the main function that handles command-line
    execution logic.
    
    .PARAMETER Path
    Path to a markdown file to render. If not specified, reads from pipeline input.
    
    .PARAMETER InputObject
    Markdown content passed via pipeline.
    
    .EXAMPLE
    Invoke-PSGlow "README.md"
    Renders the README.md file to the terminal.
    
    .EXAMPLE
    "# Heading" | Invoke-PSGlow
    Renders piped markdown content to the terminal.
    
    .EXAMPLE
    Get-Content document.md -Raw | Invoke-PSGlow
    Renders the content of a markdown file via pipeline.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path,
        
        [Parameter(ValueFromPipeline = $true)]
        [string]$InputObject
    )
    
    begin {
        $pipelineContent = @()
    }
    
    process {
        if ($InputObject) {
            # Collect pipeline input
            $pipelineContent += $InputObject
        }
    }
    
    end {
        if ($pipelineContent.Count -gt 0) {
            # Handle piped input
            $content = $pipelineContent -join "`n"
            if (-not [string]::IsNullOrWhiteSpace($content)) {
                Render-Markdown $content
            }
            else {
                Write-Error "No input provided. Use: Invoke-PSGlow <file> or pipe content to Invoke-PSGlow"
            }
        }
        elseif ($Path) {
            # Handle file input
            if (Test-Path $Path) {
                try {
                    $content = Get-Content -Path $Path -Raw
                    Render-Markdown $content
                }
                catch {
                    Write-Error "Error reading file '$Path': $_"
                }
            }
            else {
                Write-Error "File not found: $Path"
            }
        }
        else {
            # No file path and no pipeline input - try reading from stdin
            try {
                $reader = [System.IO.StreamReader]::new([Console]::OpenStandardInput())
                $content = $reader.ReadToEnd()
                $reader.Close()
                
                if (-not [string]::IsNullOrWhiteSpace($content)) {
                    Render-Markdown $content
                } else {
                    Write-Error "No input provided. Use: Invoke-PSGlow <file> or pipe content to Invoke-PSGlow"
                }
            }
            catch {
                Write-Error "No input provided. Use: Invoke-PSGlow <file> or pipe content to Invoke-PSGlow"
            }
        }
    }
}