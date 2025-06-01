function Format-MarkdownLine {
    <#
    .SYNOPSIS
    Formats a single line of markdown text with appropriate ANSI styling.
    
    .DESCRIPTION
    Processes a line of markdown text and applies ANSI formatting for headings,
    bullet lists, ordered lists, and inline formatting elements.
    
    .PARAMETER Line
    The line of markdown text to format.
    
    .EXAMPLE
    Format-MarkdownLine "# Main Heading"
    Returns the heading with cyan bold formatting and proper indentation.
    
    .EXAMPLE
    Format-MarkdownLine "* Bullet item with **bold** text"
    Returns a formatted bullet point with bold text styling.
    #>
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