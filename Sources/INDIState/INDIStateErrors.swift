import Foundation
import INDIProtocol

public enum INDIPropertyErrors: Error {
    case valueNotFound(message: String, propertyName: INDIPropertyName, valueName: INDIPropertyValueName)
}

public enum INDISwitchRuleErrors: Error {
    case atMostOneRuleViolation(message: String, values: [SwitchValue])
    case oneOfManyRuleViolation(message: String, values: [SwitchValue])
}