//
//  Download.swift
//  BarcodeApp
//
//  Created by mac-089-71 on 10/31/18.
//  Copyright © 2018 VPavelDm. All rights reserved.
//

import Foundation
import RxSwift

class Download {
    
    var progressObservable: Observable<Float> {
        return progressSubject
    }
    
    func updateAndNotifySubscribers(progress: Float) {
        currentProgress = progress
        progressSubject.onNext(progress)
        if currentProgress == 1.0 {
            progressSubject.onCompleted()
        }
    }
    
    private      var progressSubject = PublishSubject<Float>()
    private(set) var currentProgress: Float = 0
    
}
