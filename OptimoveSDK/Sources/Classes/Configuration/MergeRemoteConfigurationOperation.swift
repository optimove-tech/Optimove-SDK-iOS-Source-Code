//  Copyright © 2019 Optimove. All rights reserved.

import Foundation
import OptimoveCore

final class MergeRemoteConfigurationOperation: AsyncOperation {
    private let repository: ConfigurationRepository

    init(repository: ConfigurationRepository) {
        self.repository = repository
    }

    override func main() {
        guard !isCancelled else { return }
        state = .executing
        do {
            let globalConfig = try repository.getGlobal()
            let tenantConfig = try repository.getTenant()
            Logger.debug("Setup components from remote.")

            let builder = ConfigurationBuilder(globalConfig: globalConfig, tenantConfig: tenantConfig)
            let configuration = builder.build()

            // Set the Configuration type for the runtime usage.
            try repository.setConfiguration(configuration)
        } catch {
            Logger.error(error.localizedDescription)
        }
        state = .finished
    }
}

#if swift(>=5.5)
extension MergeRemoteConfigurationOperation: @unchecked Sendable {}
#endif
