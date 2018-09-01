//
//  ViewController.swift
//  Schedulers
//
//  Created by Fernando Mota e Silva on 26/07/2018.
//  Copyright © 2018 HalphDem. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let background = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    
    let observable = Observable<Int>.create { observer in
        //CODIGO DE SUBSCRIPTION
        if Thread.current.isMainThread {
            print("[ELEMENT] Executando na main thread!\n\n")
        } else {
            print("[ELEMENT] Executando em ota thread!\n\n")
        }
        observer.onNext(1)
        sleep(2)
        observer.onCompleted()
        return Disposables.create()
    }
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        observable
            .map { [weak self] value -> String in
                self?.whichThread(local: "MAP")
                return "\(value)"
            }
            .subscribeOn(background)
            .observeOn(MainScheduler.instance)
            .filter { [weak self] value in
                self?.whichThread(local: "FILTER")
                return "2" == value || "1" == value
            }
            
            .subscribe(onNext: { [weak self] _ in
                //CODIGO DE OBSERVATION
                self?.whichThread(local: "SUBSCRIBE")
            }, onError: { erro in
                print("Deu ruim")
            }, onCompleted: { [weak self] in
                //CODIGO DE OBSERVATION
                self?.whichThread(local: "COMPLETED")
            }).disposed(by: bag)
        
    }

    func whichThread(local: String) {
        if Thread.current.isMainThread {
            print("[\(local)] Executando na main thread!\n\n")
        } else {
            print("[\(local)] Executando em ota thread!\n\n")
        }
    }

}

