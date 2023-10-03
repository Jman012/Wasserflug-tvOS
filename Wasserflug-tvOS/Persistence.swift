import CoreData

struct PersistenceController {
	static let shared = PersistenceController()
	
	static let previewBlogPostId = "previewBlogPostId"
	static let previewVideoId0 = "previewVideoId0"
	static let previewVideoId25 = "previewVideoId25"
	static let previewVideoId50 = "previewVideoId50"
	static let previewVideoId75 = "previewVideoId75"
	static let previewVideoId100 = "previewVideoId100"

	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		
		// Mock seed data
		do {
			let newWatchProgress = WatchProgress(context: viewContext)
			newWatchProgress.blogPostId = Self.previewBlogPostId
			newWatchProgress.videoId = Self.previewVideoId0
			newWatchProgress.progress = 0.1
		}
		
		do {
			let newWatchProgress = WatchProgress(context: viewContext)
			newWatchProgress.blogPostId = Self.previewBlogPostId
			newWatchProgress.videoId = Self.previewVideoId25
			newWatchProgress.progress = 0.25
		}
		
		do {
			let newWatchProgress = WatchProgress(context: viewContext)
			newWatchProgress.blogPostId = Self.previewBlogPostId
			newWatchProgress.videoId = Self.previewVideoId50
			newWatchProgress.progress = 0.50
		}
		
//		do {
		let newWatchProgress = WatchProgress(context: viewContext)
		newWatchProgress.blogPostId = Self.previewBlogPostId
		newWatchProgress.videoId = Self.previewVideoId75
		newWatchProgress.progress = 0.75
//		}
		
		do {
			let newWatchProgress = WatchProgress(context: viewContext)
			newWatchProgress.blogPostId = Self.previewBlogPostId
			newWatchProgress.videoId = Self.previewVideoId100
			newWatchProgress.progress = 1.00
		}
		
		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()

	let container: NSPersistentContainer

	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "Wasserflug")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		container.viewContext.automaticallyMergesChangesFromParent = true
		container.loadPersistentStores(completionHandler: { storeDescription, error in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
	}
}
