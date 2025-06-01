# psglow

Terminal Markdown Renderer for PowerShell

## Overview

`psglow` is a PowerShell script that renders Markdown to the terminal with ANSI formatting. It provides beautiful, colorized output for Markdown files and piped content.

## Features

- **Headings** (#, ##, etc.) - Rendered in cyan with indentation by level
- **Bold text** (**text**) - ANSI bold formatting
- **Italic text** (*text*) - ANSI italic formatting  
- **Links** ([label](url)) - Underlined blue text with dimmed URL in parentheses
- **Bullet lists** (*, -, +) - Yellow bullet points
- **Ordered lists** (1., 2.) - Plain text formatting
- **Code fences** (``` or ~~~) - Dimmed, indented blocks with language labels
- **Tables** - Formatted tables with alignment support and bold headers
- **Nested formatting** - Supports bold with nested italic
- **Graceful fallback** - Unsupported content passes through unchanged

## Usage

### File Input
```powershell
# Render a Markdown file
psglow README.md
pwsh -File psglow.ps1 README.md
```

### Piped Input
```powershell
# Pipe Markdown content
"## Heading" | psglow
echo "**Bold** and *italic* text" | pwsh -File psglow.ps1
```

### Cross-platform
The script works on Windows, macOS, and Linux with PowerShell 7+.

## Examples

```markdown
# Main Title
This has **bold** and *italic* text.

## Subtitle
Here's a [link](https://example.com).

### Lists
* First bullet
* Second bullet

1. First item
2. Second item
```

### Code Block
```powershell
Get-Process | Where-Object CPU -gt 100
```

### Tables
| Name | Role | Status |
|------|:----:|--------|
| Alice | Developer | Active |
| Bob | Designer | *Away* |

## Installation

1. Clone or download `psglow.ps1`
2. Make it executable: `chmod +x psglow.ps1`
3. Run with: `pwsh -File psglow.ps1 <file>` or use the provided wrapper script

## Requirements

- PowerShell 7.0 or later
- Terminal with ANSI color support
