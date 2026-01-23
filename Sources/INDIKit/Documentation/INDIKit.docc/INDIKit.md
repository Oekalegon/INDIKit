# ``INDIKit``

INDIKit is a Swift package for communicating with INDI servers. You will be able to build INDI clients
with this package so that you can controll astronomical equipment using custom made Swift apps.

@Image(source: "INDIKit-logo", alt: "INDIKit logo")

## Overview

`INDIKit` is a Swift client library for the INDI protocol, which is defined and implemented by the [INDI project](https://indilib.org/). It lets you talk to an INDI server from Swift, so your apps can discover devices, send commands, and react to status updates over the INDI protocol without having to deal with its low‑level details.

`INDIKit` is a convenience module that re-exports all INDIKit modules. For more granular control, you can import individual modules:

- ``INDIProtocol`` - Core protocol implementation (parsing, messages, server communication)
- ``INDIState`` - State management for devices and properties
- ``INDIStateUI`` - SwiftUI wrappers with @Observable

## Topics

### Essentials

- ``INDIKit/INDIKit`` - Convenience wrapper that imports all modules

### Modules

- ``INDIProtocol`` - Core protocol implementation
- ``INDIState`` - State management
- ``INDIStateUI`` - SwiftUI integration
