import Logging
import MCP
import ServiceLifecycle

struct MCPService: Service {
    let server: Server
    let transport: Transport

    init(server: Server, transport: Transport) {
        self.server = server
        self.transport = transport
    }

    func run() async throws {
        // Start the server
        try await server.start(transport: transport)

        while true {
            try Task.checkCancellation()
            try await Task.sleep(for: .seconds(1))
        }
    }

    func shutdown() async throws {
        // Gracefully shutdown the server
        await server.stop()
    }
}

let logger = Logger(label: "com.indiepitcher.mcp-server")

// Create the MCP server
let server = Server(
    name: "IndiePitcherModelServer",
    version: "1.0.0",
    capabilities: .init(
        prompts: .init(listChanged: true),
        resources: .init(subscribe: true, listChanged: true),
        tools: .init(listChanged: true)
    ),
)

// Add handlers directly to the server
await server.withMethodHandler(ListTools.self) { _ in
    // Your implementation
    return .init(tools: [
        Tool(
            name: "send-email", description: "Send email using IndiePitcher",
            inputSchema: .object([
                "to": .string(
                    "Can be just an email \"john@example.com\", or an email with a neme \"John Doe john@example.com\""
                ),
                "subject": .string("The subject of the email."),
                "body": .string("The body of the email. Supports markdown and HTML"),
                "bodyFormat": .string(
                    "The format of the body. Can be \"markdown\" or \"html\""
                ),
            ]))
    ])
}

await server.withMethodHandler(CallTool.self) { params in
    switch params.name {
    case "send-email":
        // Your implementation
        let to = params.arguments?["to"]?.stringValue ?? ""
        let subject = params.arguments?["subject"]?.stringValue ?? ""
        let body = params.arguments?["body"]?.stringValue ?? ""
        let bodyFormat = params.arguments?["bodyFormat"]?.stringValue ?? ""

        // Here you would send the email using the provided parameters
        logger.info("Sending email to \(to) with subject \(subject) and body \(body.prefix(20))...")

        return .init(content: [.text("Email sent successfully")])
    default:
        return .init(content: [.text("Unknown tool")], isError: true)
    }
}

// Create MCP service and other services
let transport = StdioTransport(logger: logger)
let mcpService = MCPService(server: server, transport: transport)

// Create service group with signal handling
let serviceGroup = ServiceGroup(
    services: [mcpService],
    gracefulShutdownSignals: [.sigterm],
    logger: logger
)

// Run the service group - this blocks until shutdown
try await serviceGroup.run()

logger.info("Bye bye")
