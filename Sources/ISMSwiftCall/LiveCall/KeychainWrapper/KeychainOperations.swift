import Foundation
import Security

internal class KeychainOperations: NSObject {
    // Unique identifier for SDK keychain entries
    // Generate unique service name based on host app's bundle ID
     private static var sdkServiceName: String {
         guard let bundleID = Bundle.main.bundleIdentifier else {
             return "com.isometrik.call.keychain.unknownApp"
         }
         return "com.isometrik.call.keychain.\(bundleID)"
     }
    
    private static let sdkPrefix = "ISMCall_"

    /**
     Function to add an item to keychain
     */
    internal static func add(value: Data, account: String) throws {
        let prefixedAccount = sdkPrefix + account
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: prefixedAccount,
            kSecAttrService as String: sdkServiceName,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: value
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.operationError }
    }

    /**
     Function to update an item in keychain
     */
    internal static func update(value: Data, account: String) throws {
        let prefixedAccount = sdkPrefix + account

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: prefixedAccount,
            kSecAttrService as String: sdkServiceName
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: value
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.operationError }
    }

    /**
     Function to retrieve an item from keychain
     */
    internal static func retrieve(account: String) throws -> Data? {
        let prefixedAccount = sdkPrefix + account
        
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: prefixedAccount,
            kSecAttrService as String: sdkServiceName,
            kSecReturnData as String: true
        ]

        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.operationError
        }
    }

    /**
     Function to delete a single item
     */
    internal static func delete(account: String) throws {
        let prefixedAccount = sdkPrefix + account

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: prefixedAccount,
            kSecAttrService as String: sdkServiceName
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.operationError }
    }

    /**
     Function to delete all SDK-specific keychain items
     */
    internal static func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: sdkServiceName
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.operationError }
    }

    /**
     Function to check if a keychain item exists
     */
    internal static func exists(account: String) throws -> Bool {
        let prefixedAccount = sdkPrefix + account

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: prefixedAccount,
            kSecAttrService as String: sdkServiceName,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainError.operationError
        }
    }
}
