//
//  Functions.swift
//  Location
//
//  Created by MARC on 4/6/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import Foundation

let applicationDocumentDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

let coreDateSaveFail = Notification.Name("coreDateSaveFail")

func afterdelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

func coreDataDidFailSaving(_ error: Error) {
    print("fatal error\(error)")
    NotificationCenter.default.post(name: coreDateSaveFail, object: nil)
}


