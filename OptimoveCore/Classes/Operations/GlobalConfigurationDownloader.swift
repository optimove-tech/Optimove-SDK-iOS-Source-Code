//  Copyright © 2019 Optimove. All rights reserved.

public final class GlobalConfigurationDownloader: AsyncOperation {

    private let networking: RemoteConfigurationNetworking
    private let repository: ConfigurationRepository

    public init(networking: RemoteConfigurationNetworking,
         repository: ConfigurationRepository) {
        self.networking = networking
        self.repository = repository
    }

    public override func main() {
        state = .executing
        networking.getGlobalConfiguration { result in
            do {
                let global = try result.get()
                try self.repository.saveGlobal(global)
            } catch {
//                OptiLoggerMessages.logError(error: error)
            }
            self.state = .finished
        }
    }
}