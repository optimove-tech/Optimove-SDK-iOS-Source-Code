//  Copyright © 2019 Optimove. All rights reserved.

import OptimoveCore

final class GlobalConfigurationDownloader: AsyncOperation {
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
        networking.getGlobalConfiguration { result in
            do {
                let global = try result.get()
                try self.repository.saveGlobal(global)
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
extension GlobalConfigurationDownloader: @unchecked Sendable {}
#endif
