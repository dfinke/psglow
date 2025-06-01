function Format-InlineMarkdown {
    <#
    .SYNOPSIS
    Formats inline markdown elements within text.
    
    .DESCRIPTION
    Processes inline markdown formatting including links, inline code,
    bold text, and italic text. Handles nested formatting properly
    and applies appropriate ANSI escape codes.
    
    .PARAMETER Text
    The text containing inline markdown to format.
    
    .EXAMPLE
    Format-InlineMarkdown "This has **bold** and *italic* text"
    Returns text with proper ANSI formatting for bold and italic.
    
    .EXAMPLE
    Format-InlineMarkdown "Check out this [link](https://example.com)"
    Returns formatted text with colored and underlined link.
    
    .EXAMPLE
    Format-InlineMarkdown "Here's some `inline code` to highlight"
    Returns text with highlighted inline code.
    #>
    param([string]$Text)
    
    $result = $Text
    
    # Process links [text](url) first
    $result = $result -replace '\[([^\]]+)\]\(([^)]+)\)', "$($script:AnsiCodes.Blue)$($script:AnsiCodes.Underline)`$1$($script:AnsiCodes.Reset) ($($script:AnsiCodes.Dim)`$2$($script:AnsiCodes.Reset))"
    
    # Process inline code `code` before other formatting
    $result = $result -replace '`([^`]+)`', "$($script:AnsiCodes.BgDarkRed)$($script:AnsiCodes.BrightWhite)`$1$($script:AnsiCodes.Reset)"
    
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