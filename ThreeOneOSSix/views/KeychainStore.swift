import Foundation
import Security

/// Guarda textos en el Keychain para que sobrevivan al cerrar la app
/// (la key de acceso) y, normalmente, también a desinstalarla (el ID del dispositivo).
enum KeychainStore {
    private static let service = "com.si.app.accesskey"
    static let defaultAccount = "key"

    static func save(_ value: String,
                     account: String = defaultAccount,
                     thisDeviceOnly: Bool = false) {
        delete(account: account)
        let accessible = thisDeviceOnly
            ? kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            : kSecAttrAccessibleAfterFirstUnlock
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: accessible,
            kSecValueData as String: Data(value.utf8)
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(account: String = defaultAccount) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(account: String = defaultAccount) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}