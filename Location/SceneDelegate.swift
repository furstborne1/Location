//
//  SceneDelegate.swift
//  Location
//
//  Created by MARC on 4/5/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "DataModel")
          container.loadPersistentStores {(storeDescription, error) in
              if let error = error {
                  fatalError("could not load\(error)")
              }
          }
          return container
      }()
      
      lazy var managedObjectContext: NSManagedObjectContext = {
          return persistentContainer.viewContext
      }()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let tabController = window!.rootViewController as! UITabBarController
        if let tabBarController = tabController.viewControllers {
            var navController = tabBarController[0] as! UINavigationController
            let controller = navController.viewControllers.first as! CurrentLocationVC
            controller.managedObjectContext = managedObjectContext
            /// -2
            navController = tabBarController[1] as! UINavigationController
            let controller1 = navController.viewControllers.first as! LocationsViewController
            controller1.managedObjectContext = managedObjectContext
            let _ = controller1.view
            /// -3
            navController = tabBarController[2] as! UINavigationController
            let controller2 = navController.viewControllers.first as! MapViewController
            controller2.managedObjectContext = managedObjectContext
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    //MARK: listen fo coredata error
     func listenForFatalErrorCoreData() {
         NotificationCenter.default.addObserver(forName: coreDateSaveFail, object: nil, queue: OperationQueue.main) { (notification) in
             let message = """
             There was a fatal error in the app and it cannot continue.
             Press OK to terminate the app. Sorry for the inconvenience.
             """
             
             let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .actionSheet)
             let action = UIAlertAction(title: "Ok", style: .default) { _ in
                 let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Core Data Error", userInfo: nil)
                 exception.raise()
             }
             alert.addAction(action)
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
         }
     }


}

