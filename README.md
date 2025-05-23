# indiepitcher-mcp
IndiePitcher MCP server

This is heavily WIP

- [ ] Actually integrate IndiePitcher SDK to send actual email
- [ ] Implement passing of IndiePitcher API key
- [ ] Figure out deployment to smithery.ai

## How to use locally

### Build the server

Make sure that you have Swift installed. 
- The easiest way on macOS is to download Xcode from the macOS App Store. 
- You can alternatively follow the instalation guide on the [swift.org](https://www.swift.org/install)
  - Works on linux, not sure about Windows TBH

```bash
git clone https://github.com/IndiePitcher/indiepitcher-mcp.git
cd indiepitcher-mcp
swift build --configuration release
```

### Integrate the server

#### Claude Desktop

Update `claude_desktop_config.json`

```json
{
  "mcpServers": {
    "indiepitcher-server": {
      "command": "/[replace this part]/indiepitcher-mcp/.build/debug/indiepitcher-mcp",
      "args": []
    }
  }
}

```