
import Foundation

public class KeychainWrapper: NSObject {
    
    /**
     Function to store a keychain item
     - parameters:
        - value: Value to store in keychain in `data` format
        - account: Account name for keychain item
     */
    public static func set(value: Data, account: String) throws {
        // If the value exists `update the value`
        if try KeychainOperations.exists(account: account) {
            try KeychainOperations.update(value: value, account: account)
        } else {
            // Just insert
            try KeychainOperations.add(value: value, account: account)
        }
    }
    
    /**
     Function to retrieve an item in `Data` format (If not present, returns nil)
     - parameters:
        - account: Account name for keychain item
     - returns: Data from stored item
     */
    public static func get(account: String) throws -> Data? {
        if try KeychainOperations.exists(account: account) {
            return try KeychainOperations.retrieve(account: account)
        } else {
            throw KeychainError.operationError
        }
    }
    
    /**
     Function to delete a single item
     - parameters:
        - account: Account name for keychain item
     */
    public static func delete(account: String) throws {
        if try KeychainOperations.exists(account: account) {
            try KeychainOperations.delete(account: account)
        } else {
            throw KeychainError.operationError
        }
    }
    
    /**
     Function to delete all items
     */
    public static func deleteAll() throws {
        try KeychainOperations.deleteAll()
    }
}


