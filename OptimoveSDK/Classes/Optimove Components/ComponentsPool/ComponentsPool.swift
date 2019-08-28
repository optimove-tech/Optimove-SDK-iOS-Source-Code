//  Copyright © 2019 Optimove. All rights reserved.

import Foundation
import OptimoveCore

typealias ComponentsPool = Pushable & Eventable

protocol MutableComponentsPool: ComponentsPool {
    func addEventableComponent(_: Eventable)
    func addPushableComponent(_: Pushable)
}

final class ComponentsPoolImpl {

    private let componentFactory: ComponentFactory

    private var eventableComponents: [Eventable] = []
    private var pushableComponents: [Pushable] = []

    init(componentFactory: ComponentFactory) {
        self.componentFactory = componentFactory
    }

}

extension ComponentsPoolImpl: Eventable {

    func setUserId(_ userId: String) {
        eventableComponents.forEach { component in
            component.setUserId(userId)
        }
        // TODO: Handle by checking `eventableComponents.isEmpty` after the logger refactoring will be completed.
        if !RunningFlagsIndication.isComponentRunning(.optiTrack) {
            Logger.error(
                "OptiTrack: Event user id could not be reported. Reason: Component is not running."
            )
        }
    }

    func report(event: OptimoveEvent) throws {
        try eventableComponents.forEach { component in
            try component.report(event: event)
        }
        // TODO: Handle by checking `eventableComponents.isEmpty` after the logger refactoring will be completed.
        if !RunningFlagsIndication.isComponentRunning(.optiTrack) {
            Logger.error(
                "OptiTrack: Event '\(event.name)' could not be reported. Reason: Component is not running."
            )
        }
        if !RunningFlagsIndication.isComponentRunning(.realtime) {
            Logger.error(
                "Realtime: Event '\(event.name)' could not be reported. Reason: Component is not running."
            )
        }
    }

    func reportScreenEvent(customURL: String, pageTitle: String, category: String?) throws {
        try eventableComponents.forEach { component in
            try component.reportScreenEvent(customURL: customURL, pageTitle: pageTitle, category: category)
        }
    }

    func dispatchNow() {
        eventableComponents.forEach { component in
            component.dispatchNow()
        }
    }

}

extension ComponentsPoolImpl: Pushable {

    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushableComponents.forEach { component in
            component.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    func performRegistration() {
        pushableComponents.forEach { component in
            component.performRegistration()
        }
        // TODO: Handle by checking `pushableComponents.isEmpty` after the logger refactoring will be completed.
        if !RunningFlagsIndication.isComponentRunning(.optiPush) {
            Logger.error(
                "OptiPush: Event user id could not be reported. Reason: Component is not running."
            )
        }
    }

    func subscribeToTopic(topic: String) {
        pushableComponents.forEach { component in
            component.subscribeToTopic(topic: topic)
        }
    }

    func unsubscribeFromTopic(topic: String) {
        pushableComponents.forEach { component in
            component.unsubscribeFromTopic(topic: topic)
        }
    }

}

extension ComponentsPoolImpl: MutableComponentsPool {

    func addEventableComponent(_ component: Eventable) {
        eventableComponents.append(component)
    }

    func addPushableComponent(_ component: Pushable) {
        pushableComponents.append(component)
    }

}