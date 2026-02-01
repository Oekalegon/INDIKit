# ``INDIProtocol``

INDIProtocol provides the core implementation of the INDI protocol for communicating with INDI servers.

## Overview

`INDIProtocol` is the foundation of INDIKit, implementing the INDI protocol specification. It provides:

- **Message Parsing**: Parse XML messages from INDI servers into structured Swift types
- **Message Serialization**: Convert Swift types back to INDI XML format
- **Server Communication**: Connect to and communicate with INDI servers
- **Protocol Types**: All INDI message types, operations, and enums

## Topics

### Essentials

- ``INDIProtocol/INDIServer`` - Connect to and communicate with INDI servers
- ``INDIProtocol/INDIMessage`` - INDI protocol messages
- ``INDIProtocol/INDIOperation`` - INDI operation types

### Message Types

- ``INDIProtocol/INDIGetProperties`` - Request properties from server
- ``INDIProtocol/INDISetProperty`` - Set property values
- ``INDIProtocol/INDIUpdateProperty`` - Property updates from server
- ``INDIProtocol/INDIDefineProperty`` - Property definitions from server
- ``INDIProtocol/INDIEnableBlob`` - Enable/disable BLOB transfers
- ``INDIProtocol/INDIServerMessage`` - Server informational messages
- ``INDIProtocol/INDIDeleteProperty`` - Property deletion notifications
- ``INDIProtocol/INDIPingRequest`` - Ping request from server (during binary transfers)
- ``INDIProtocol/INDIPingReply`` - Ping reply from client (response to pingRequest)

### Core Types

- ``INDIProtocol/INDIValue`` - Property values
- ``INDIProtocol/INDIPropertyType`` - Property type enumeration
- ``INDIProtocol/INDIPropertyName`` - Known property names
- ``INDIProtocol/INDIState`` - Property state enumeration
- ``INDIProtocol/INDIDiagnostics`` - Diagnostic messages

