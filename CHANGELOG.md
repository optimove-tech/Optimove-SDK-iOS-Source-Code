# Changelog

## 6.1.0

- Fix invalidating sessions on NetworkClientImpl deinit
- Fix removed tasks to support pre 5.5 swift versions
- Fix Xcode 16 OpitmoveSDK warnings

## 6.0.2

- Fix same immediate events sent multiple times

## 6.0.1

- Fix in app presentation issue in orientation change

## 6.0.0

- Add Preference Center feature. The new functionality is available through the following methods:
    - `OptimovePreferenceCenter.getInstance().setCustomerPreferencesAsync()`
    - `OptimovePreferenceCenter.getInstance().getPreferencesAsync()`
    
Breaking changes:
- iOS 13 required for using Preference Center
- removed `OptimoveConfigBuilder.setCredentials` unintentionally public method

## 5.9.0

- Remove `SetUserAgent` event

## 5.8.0

- Add a new public API `Optimove.shared.urlOpened(url: url)` to allow easily forwarding urls to Optimove instead of relying on AppDeletegate's `application(_:continue:restorationHandler:)`
- Fix deeplink decoding issue
- Fix immediate initialization of the SDK

## 5.7.0

- Add Privacy Manifest
- Fix explicit `self` for `weak self` captures to allow pre 5.8 Swift compilation
- Remove web to app banner code

## 5.6.0

- Support the delayed configuration for SDK. Add new public APIs:
    - `OptimoveConfigBuilder(region: Region, features: [Feature])` - call for creating delayed configuration builder.
    - `Optimove.setCredentials(optimoveCredentials: String?, optimobileCredentials: String?)` - call for setting credentials for delayed configuration.

## 5.5.0

- Add a new public API `Optimove.shared.trackOpenMetric(userInfo: [AnyHashable: Any])` - to track the open metric of a push notification, when UserNotificationCenter delegate is not available.
- Increased the minimum supported iOS version to 12.0 for Carthage builds.

## 5.4.0

- Add the initial visitor identifier getter to public API. The new API is public available via the following methods:
  - `Optimove.getInitialVisitorID()`.
  - `Optimove.shared.getInitialVisitorID()`.

## 5.3.0

- Add ability to pause & resume in-app message display (#72)
- Improve Kumulos to Optimove SDK upgrade path (#71)

## 5.2.2

- Fixed a crash when there are too many event parameters reported.

## 5.2.1

- Avoid force-unwrapping of NSManagedObjectContext, which could be the reason for occasional crashes.

## 5.2.0

- In order to support geofencing and beacons, add public API methods to track location and beacon proximity.

## 5.1.1

- Expose methods to support hybrid SDKs

## 5.1.0

- **added** `signOutUser` API - Unassociate the current customer with the device, returning to a anonymous visitor state

- **added** `pushUnregister` API - Opt the device out from push notifications

## 5.0.0

Major breaking update - [Migration guide](https://github.com/optimove-tech/Optimove-SDK-iOS/wiki/Migration-guide-from-3.x-to-5.x)

- Deprecated OptiPush and implemented new messaging platform
- Added In-App Messaging, Message Inbox and Deferred Deep Linking features

## 3.6.0 (unreleased)

- **added** `getVisitorID` API.

## 3.5.4

- **fix** calling `registerUser` API with previously reported email resulted in user id report failure.

## 3.5.3

- **fix** using `registerUser` call.

## 3.5.2

- **remove** AdSupport dependencies.

## 3.5.1

- **fix** using the pipeline before configs are ready.

## 3.5.0

- **added** push notifications channels.

## 3.4.2

- added a safe way of preforming CoreData Context's operations.

## 3.4.1

- **fix** AppGroup migration.

## 3.4.0

- **added** generating and handling of a request tracing ID.

## 3.3.0

- **change** migrate the storage from an App Group to an main container.
- **support** iOS 14.
- **fix** a generation of an update visitor id.

## 3.2.0

- **add** new deeplinks - no need to convert from dynamic links.
- **fix** do not send events with errors to realtime.
- **fix** crash in NSE.

## 3.1.1

- **fix** Attempted to dereference garbage pointer: #16.

## 3.1.0

- **add** events flow visibility (validation results as a part of an event).
- **add** `eventId` in the event metadata.
- **add** CoreData migration.
- **improve** Notification Service extension - reduce memory consumption.
- **improve** APNS-token gathering.

## 3.0.1

- **fixed** core data a context concurrency violation.

## 3.0.0

Major breaking update - [Migration guide](https://github.com/optimove-tech/Optimove-SDK-iOS/wiki/Migration-guide-from-2.x-to-3.x)

- **add** a support of the new Optistream events.
- **add** Airship integration.
- **improve** persistent layer for events.
- **change** global config to v4.
- **remove** the Matomo SDK dependency.
- **remove** deprecated API.

## 2.12.1

- **fix** calling UIKit method in the Main thread.

## 2.12.0

- **added** fetching geo-location data if available.
- **change** default endpoint for remote logging.

## 2.11.1

- **fix** saving a control state of a push campaign.

## 2.11.0

- **add** method `disablePushCampaigns`.
- **add** method `enablePushCampaigns`.

## 2.10.0

- **add** SPM support.
- **remove** test mode API.
- **remove** firebase dependency.

## 2.9.1

- **hotfix** safety wrap the SDK initialization to prevent from a crash regarding a corrupt file system access.

## 2.9.0

- **fix** carthage firebase dependency for version 6.15.
- **fix** set_user_id issue if it calls before `configure`.

## 2.8.1

- **fix** xcode 10 build.

## 2.8.0

- **improve** an apns environment checking.
- **improve** updating for an actual token.
- **change** enabling debug logging.
- **fix** main-thread sanity warnings.

## 2.7.0

- **added** expose version number
- **changed** access level for notification service operations.

## 2.6.0

- **changed** API communication
- **fixed** error handling
- **fixed** notification payload model (optional title)

## 2.5.1

- **fixed** compatibility with Swift 5.0.3.
- **fixed** `OptimoveCore` explicit version for other Optimove frameworks.

## 2.5.0

- **added** new API `didReceivePushAuthorization(fromUserNotificationCenter: Bool)`.
- **added** support for `UNAuthorizationStatus.provisional`.
- **added** handling Notification authorization changes on an app lifecycle.
- **BREAKING change** `OptimoveEvent` is now available under the `OptimoveCore` framework instead of the `OptimoveSDK`.

> The Optimove SDK is following _semvar_. Exceptionally, this change is not considered a major release.

## 2.4.0

- **introduced** a new API for working with Apple tokens directly.

## 2.3.0

- **removed** `OptimoveStateListener` – use the SDK directly.
- **added** `OptimoveCore` – a framework for share a code-base between the SDK and the NSE.
- **changed** `OptimoveEvent` – moved to the `OptimoveCore` module.

## 2.2.2

- **fixed** – The realtime race condition issue fixed on the mobile-side by introducing a delay between requests.
- **fixed** – Notification Payload's deep link property changed to optional.

- **introduced** – `OPTIMOVE_RELEASE_VERSION` key used a value for unifying apps version.
- **introduced** – Experimentally Carthage support.

## 2.2.1

- **fixed** – The SDK state listeners never called.

## 2.2.0

- **introduced** – `OPTIMOVE_SDK_ENVIRONMENT` key used for choosing a logging endpoint. The default value is `production`.

## 2.1.0

- Updated Firebase versions.
  - FirebaseDynamicLinks, '4.0.0'
  - FirebaseMessaging, '4.0.2'

## 2.0.2

- **deprecated** – `registerUser(email:userId:)` and exposed `registerUser(sdkId:email)`

## 2.0.1

- Internal bug fixes.
