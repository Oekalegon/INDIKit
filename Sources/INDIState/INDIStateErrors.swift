import Foundation
import INDIProtocol

public enum INDIPropertyErrors: Error {
    case valueNotFound(message: String, propertyName: INDIPropertyName, valueName: INDIPropertyValueName)
    case lightValueIsReadOnly(message: String, propertyName: INDIPropertyName)
}

public enum INDISwitchRuleErrors: Error {
    case atMostOneRuleViolation(message: String, values: [SwitchValue])
    case oneOfManyRuleViolation(message: String, values: [SwitchValue])
}