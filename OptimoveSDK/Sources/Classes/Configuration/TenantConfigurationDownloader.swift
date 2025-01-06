//  Copyright © 2019 Optimove. All rights reserved.

import Foundation
import OptimoveCore

final class TenantConfigurationDownloader: AsyncOperation {
    private let networking: RemoteConfigurationNetworking
    private let repository: ConfigurationRepository

    init(networking: RemoteConfigurationNetworking,
         repository: ConfigurationRepository)
    {
        self.networking = networking
        self.repository = repository
    }

    override func main() {
        guard !isCancelled else { return }
        state = .executing
        networking.getTenantConfiguration { result in
            do {
                let tenant = try result.get()
                try self.repository.saveTenant(tenant)
            } catch let DecodingError.dataCorrupted(context) {
                Logger.error(context.debugDescription)
            } catch let DecodingError.keyNotFound(key, context) {
                Logger.error("Key '\(key)' not found: \(context.debugDescription)\ncodingPath: \(context.codingPath)")
            } catch let DecodingError.valueNotFound(value, context) {
                Logger.error("Value '\(value)' not found: \(context.debugDescription)\ncodingPath: \(context.codingPath)")
            } catch let DecodingError.typeMismatch(type, context) {
                Logger.error("Type '\(type)' mismatch: \(context.debugDescription)\ncodingPath: \(context.codingPath)")
            } catch {
                Logger.error(error.localizedDescription)
            }
            self.state = .finished
        }
    }
}

#if swift(>=5.5)
extension TenantConfigurationDownloader: @unchecked Sendable {}
#endif
