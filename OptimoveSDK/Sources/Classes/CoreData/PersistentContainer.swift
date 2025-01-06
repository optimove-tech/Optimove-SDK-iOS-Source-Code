//  Copyright © 2020 Optimove. All rights reserved.

import CoreData
import Foundation
import OptimoveCore

final class PersistentContainer: NSPersistentContainer {
    enum PersistentStoreType {
        case sql
        case inMemory

        var coreDataValue: String {
            switch self {
            case .sql:
                return NSSQLiteStoreType
            case .inMemory:
                return NSInMemoryStoreType
            }
        }
    }

    private enum Constants {
        static let modelName = "OptistreamQueue"
        static let folderName = "com.optimove.sdk.no-backup"
    }

    private let migrator: CoreDataMigratorProtocol
    private let storeType: PersistentStoreType

    init(
        modelName: String = Constants.modelName,
        version: CoreDataMigrationVersion = .current,
        migrator: CoreDataMigratorProtocol = CoreDataMigrator(),
        storeType: PersistentStoreType = .sql
    ) {
        let mom = CoreDataModelDescription.makeOptistreamEventModel(version: version)
        self.migrator = migrator
        self.storeType = storeType
        super.init(name: modelName, managedObjectModel: mom)
    }

    func loadPersistentStores(storeName: String) throws {
        guard !isThisStoreAlreadyLoaded(storeName: storeName) else { return }
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = storeType.coreDataValue
        persistentStoreDescription.url = try FileManager.default.defineStoreURL(
            folderName: Constants.folderName,
            storeName: storeName
        )
        persistentStoreDescription.shouldMigrateStoreAutomatically = false
        persistentStoreDescription.shouldInferMappingModelAutomatically = false
        persistentStoreDescriptions = [persistentStoreDescription]
        migrateStoreIfNeeded {
            self.loadPersistentStores { _, error in
                if let error = error {
                    Logger.error("Unable to load persistent stores: \(error)")
                }
            }
        }
    }

    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let storeURL = persistentStoreDescriptions.first?.url else {
            Logger.error("persistentContainer was not set up properly")
            completion()
            return
        }

        if migrator.requiresMigration(at: storeURL, toVersion: CoreDataMigrationVersion.current) {
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try self.migrator.migrateStore(at: storeURL, toVersion: CoreDataMigrationVersion.current)
                } catch {
                    Logger.error(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }

    private func isThisStoreAlreadyLoaded(storeName: String) -> Bool {
        return !persistentStoreDescriptions.compactMap { psd in
            psd.url?.deletingPathExtension().lastPathComponent
        }.filter { $0 == storeName }.isEmpty
    }
}

#if swift(>=5.5)
extension PersistentContainer: @unchecked Sendable {}
#endif

extension FileManager {
    func defineStoreURL(folderName: String, storeName: String) throws -> URL {
        let libraryDirectory = try unwrap(urls(for: .libraryDirectory, in: .userDomainMask).first)
        let libraryStoreDirectoryURL = try unwrap(libraryDirectory.appendingPathComponent(folderName))
        let storeURL = try unwrap(libraryStoreDirectoryURL.appendingPathComponent("\(storeName).sqlite"))
        guard !directoryExists(atUrl: libraryStoreDirectoryURL, isDirectory: true) else {
            return try addSkipBackupAttributeToItemAtURL(url: storeURL)
        }
        try createDirectory(at: libraryStoreDirectoryURL, withIntermediateDirectories: true)
        return try addSkipBackupAttributeToItemAtURL(url: storeURL)
    }

    func addSkipBackupAttributeToItemAtURL(url: URL) throws -> URL {
        guard directoryExists(atUrl: url, isDirectory: false) else {
            return url
        }
        var url = url
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try url.setResourceValues(resourceValues)
        return url
    }

    func directoryExists(atUrl url: URL, isDirectory: Bool) -> Bool {
        var isDirectory = ObjCBool(isDirectory)
        let exists = fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}

extension CoreDataModelDescription {
    static func makeOptistreamEventModel(version: CoreDataMigrationVersion) -> NSManagedObjectModel {
        switch version {
        case .version1:
            return makeOptistreamEventModelv1()
        case .version2:
            return makeOptistreamEventModelv2()
        }
    }

    private static func makeOptistreamEventModelv1() -> NSManagedObjectModel {
        let modelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: EventCD.entityName,
                    managedObjectClass: EventCD.self,
                    attributes: [
                        .attribute(name: #keyPath(EventCD.data), type: .binaryDataAttributeType),
                        .attribute(name: #keyPath(EventCD.type), type: .stringAttributeType),
                        .attribute(name: #keyPath(EventCD.uuid), type: .stringAttributeType),
                        .attribute(name: #keyPath(EventCD.date), type: .stringAttributeType),
                    ],
                    constraints: [#keyPath(EventCD.uuid), #keyPath(EventCD.type)]
                ),
            ]
        )
        return modelDescription.makeModel()
    }

    private static func makeOptistreamEventModelv2() -> NSManagedObjectModel {
        let modelDescription = CoreDataModelDescription(
            entities: [
                .entity(
                    name: EventCDv2.entityName,
                    managedObjectClass: EventCDv2.self,
                    attributes: [
                        .attribute(name: #keyPath(EventCDv2.data), type: .binaryDataAttributeType),
                        .attribute(name: #keyPath(EventCDv2.type), type: .stringAttributeType),
                        .attribute(name: #keyPath(EventCDv2.eventId), type: .stringAttributeType),
                        .attribute(
                            name: #keyPath(EventCDv2.creationDate),
                            type: .dateAttributeType,
                            defaultValue: Date()
                        ),
                    ],
                    constraints: [#keyPath(EventCDv2.eventId), #keyPath(EventCDv2.type)]
                ),
            ]
        )
        return modelDescription.makeModel()
    }
}
