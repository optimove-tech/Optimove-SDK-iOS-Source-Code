import Foundation
import OptimoveCore

public class OptimovePreferenceCenter {
    enum Error: LocalizedError {
        case alreadyInitialized
        case notInitialized
        case configurationIsMissing

        var errorDescription: String? {
            switch self {
            case .alreadyInitialized:
                return "The PreferenceCenterSDK has already been initialized."
            case .notInitialized:
                return "Preference center has not been initialized."
            case .configurationIsMissing:
               return "Preference center configuration is missing, but the feauture was requested. Please provide valid credentials."
            }
        }
    }

    private static var instance: OptimovePreferenceCenter?
    private var networkClient: NetworkClient?
    private var storage: OptimoveStorage?

    static var isSdkRunning: Bool {
        return Optimove.getConfig()?.getPreferenceCenterConfig() != nil
    }

    public enum ResultType {
        case success
        case errorUserNotSet
        case errorCredentialsNotSet
        case error
    }

    public typealias PreferencesGetHandler = (_ result: ResultType, _ preferences: OptimovePC.Preferences?) -> Void
    public typealias PreferencesSetHandler = (_ result: ResultType) -> Void

    public static func getInstance() throws -> OptimovePreferenceCenter {
        guard let instance = instance else {
            throw Error.notInitialized
        }
        return instance
    }

    static func initialize(with optimoveConfig: OptimoveConfig, storage: OptimoveStorage, networkClient: NetworkClient) throws {
        if instance !== nil, optimoveConfig.features.contains(.delayedConfiguration) {
            guard optimoveConfig.preferenceCenterConfig != nil else {
                throw Error.configurationIsMissing
            }
            return
        }

        guard instance == nil else {
            assertionFailure(Error.alreadyInitialized.localizedDescription)
            throw Error.alreadyInitialized
        }

        instance = OptimovePreferenceCenter(storage: storage, networkClient: networkClient)
    }

    private init(storage: OptimoveStorage, networkClient: NetworkClient) {
        self.networkClient = networkClient
        self.storage = storage
    }

    public func getPreferencesAsync(completion: @escaping PreferencesGetHandler) {
        guard let config = Optimove.getConfig()?.getPreferenceCenterConfig() else {
            Logger.error("Preference center credentials are not set")
            completion(.errorCredentialsNotSet, nil)
            return
        }

        guard
            let customerId = try? storage?.getCustomerID(),
            let visitorId = try? storage?.getVisitorID(),
            customerId != visitorId
        else {
            Logger.warn("Customer ID is not set")
            completion(.errorUserNotSet, nil)
            return
        }

        do {
            let request = try createGetPreferencesRequest(for: customerId, with: config)

            networkClient?.perform(request) { [self] result in
                switch result {
                case .success(let response):
                    do {
                        let preferences = try response.decode(to: OptimovePC.Preferences.self)
                        DispatchQueue.main.async {
                            completion(.success, preferences)
                        }
                    } catch {
                        logFailedResponse(error)
                        DispatchQueue.main.async {
                            completion(.error, nil)
                        }
                    }
                case .failure(let error):
                    logFailedResponse(error)
                    DispatchQueue.main.async {
                        completion(.error, nil)
                    }
                }
            }

        } catch {
            logFailedResponse(error)
            DispatchQueue.main.async {
                completion(.error, nil)
            }
        }
    }
    private func createGetPreferencesRequest(
        for customerId: String,
        with config: PreferenceCenterConfig) throws -> NetworkRequest {
            let (region, brandGroupId, tenantId) = getConfigValues(from: config)

            return NetworkRequest(
                method: .get,
                baseURL: URL(string: "https://preference-center-\(region).optimove.net")!,
                path: "/api/v1/preferences",
                headers: [
                    HTTPHeader(field: .accept, value: .textplain),
                    HTTPHeader(field: .tenantId, value: .tenantId(id: tenantId))
                ],
                queryItems: [
                    URLQueryItem(name: "customerId", value: customerId),
                    URLQueryItem(name: "brandGroupId", value: brandGroupId)
                ]
            )
    }

    private func getConfigValues(from config: PreferenceCenterConfig) -> (region: String, brandGroupId: String, tenantId: String) {
        let region = config.region
        let brandGroupId = config.brandGroupId
        let tenantId = config.tenantId.description
        return (region, brandGroupId, tenantId)
    }

    public func setCustomerPreferencesAsync(completion: @escaping PreferencesSetHandler, updates: [OptimovePC.PreferenceUpdate]) {
        guard let config = Optimove.getConfig()?.getPreferenceCenterConfig() else {
            Logger.error("Preference center credentials are not set")
            completion(.errorCredentialsNotSet)
            return
        }

        guard
            let customerId = try? storage?.getCustomerID(),
            let visitorId = try? storage?.getVisitorID(),
            customerId != visitorId else {
            Logger.warn("Customer ID is not set")
            completion(.errorUserNotSet)
            return
        }

        do {
            let request = try createSetPreferencesRequest(for: customerId, with: config, updates: updates)

            networkClient?.perform(request) { [self] result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.unwrap()
                        DispatchQueue.main.async {
                            completion(.success)
                        }
                    } catch {
                        logFailedResponse(error)
                        DispatchQueue.main.async {
                            completion(.error)
                        }
                    }
                case .failure(let error):
                    logFailedResponse(error)
                    DispatchQueue.main.async {
                        completion(.error)
                    }
                }
            }

        } catch {
            logFailedResponse(error)
            DispatchQueue.main.async {
                completion(.error)
            }
        }
    }

    private func createSetPreferencesRequest(
        for customerId: String,
        with config: PreferenceCenterConfig,
        updates: [OptimovePC.PreferenceUpdate]) throws -> NetworkRequest {
        let (region, brandGroupId, tenantId) = getConfigValues(from: config)

        return try NetworkRequest(
            method: .put,
            baseURL: URL(string: "https://preference-center-\(region).optimove.net")!,
            path: "/api/v1/preferences",
            headers: [
                HTTPHeader(field: .accept, value: .textplain),
                HTTPHeader(field: .tenantId, value: .tenantId(id: tenantId))
            ],
            queryItems: [
                URLQueryItem(name: "customerId", value: customerId),
                URLQueryItem(name: "brandGroupId", value: brandGroupId)
            ],
            body: updates
        )
    }

    private func logFailedResponse(_ error: Swift.Error) {
        Logger.error("Request failed with error: \(error.localizedDescription)")
    }

    private func logFailedResponse(_ response: URLResponse) {
        if let httpResponse = response as? HTTPURLResponse {
            let code = httpResponse.statusCode;
            let msg = "Request failed with code \(code): \(HTTPURLResponse.localizedString(forStatusCode: code))."

            switch httpResponse.statusCode {
            case 400:
                Logger.error("\(msg) Check preference center configuration");
            default:
                Logger.error(msg)
            }
        }
    }
}
