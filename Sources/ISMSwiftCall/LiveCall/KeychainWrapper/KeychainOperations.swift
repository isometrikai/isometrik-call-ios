import Foundation
import Security

internal class KeychainOperations: NSObject {
    /**
     Function to add an item to keychain
     - parameters:
       - value: Value to save in `data` format (String, Int, Double, Float, etc)
       - account: Account name for keychain item
     */
    internal static func add(value: Data, account: String) throws {
        guard let service = Bundle.main.bundleIdentifier else{
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: value
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.operationError }
    }

    /**
     Function to update an item to keychain
     - parameters:
       - value: Value to replace for
       - account: Account name for keychain item
     */
    internal static func update(value: Data, account: String) throws {
        guard let service = Bundle.main.bundleIdentifier else{
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: value
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.operationError }
    }

    /**
     Function to retrieve an item from keychain
     - parameters:
       - account: Account name for keychain item
     */
    internal static func retrieve(account: String) throws -> Data? {
        guard let service = Bundle.main.bundleIdentifier else{
            return nil
        }
        
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
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
     - parameters:
       - account: Account name for keychain item
     */
    internal static func delete(account: String) throws {
        guard let service = Bundle.main.bundleIdentifier else{
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.operationError }
    }

    /**
     Function to delete all items for the app
     */
    internal static func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.operationError }
    }

    /**
     Function to check if a keychain item exists
     - parameters:
       - account: String type with the name of the item to check
     - returns: Boolean type with the answer if the keychain item exists
     */
    internal static func exists(account: String) throws -> Bool {
        guard let service = Bundle.main.bundleIdentifier else{
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainError.creatingError
        }
    }
}


