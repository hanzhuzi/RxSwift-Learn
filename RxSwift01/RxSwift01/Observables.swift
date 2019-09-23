//
//  Observables.swift
//  RxSwift01
//
//  Created by 徐冉 on 2019/9/19.
//  Copyright © 2019 QK. All rights reserved.
//

import Foundation
import RxSwift

enum DataError: Error {
    
    case noData
    case timeOut
    case cantParseJSON
}

/// MAR: - Observable

/// 可以发出多个元素，和一个error事件或者complete事件
func generateObservaleSequece() -> Observable<String> {
    
    let observable = Observable<String>.create { (observer) -> Disposable in
        
        // 发出一个元素
        observer.onNext("hello, RxSwift!")
        // 结束
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    return observable
}


/// MAR: - Single
/// 要么只能发出一个元素，要么产生一个error事件
func getRepos(_ sText: String) -> Single<[String: AnyObject]> {
    
    let url = URL(string: "https://api.github.com/repos/\(sText)")!
    
    let single = Single<[String: AnyObject]>.create { (observer) -> Disposable in
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard let revData = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: revData, options: JSONSerialization.ReadingOptions.mutableContainers) else {
                    observer(.error(DataError.noData))
                    return
            }
            
            guard let dict = jsonObject as? [String: AnyObject] else {
                observer(.error(DataError.cantParseJSON))
                return
            }
            
            observer(.success(dict))
        })
        
        dataTask.resume()
        
        return Disposables.create {
            dataTask.cancel()
        }
    }
    
    return single
}

/// MARK: - Completable

/// 不发出元素，要么产生一个complete事件，要么产生一个error事件
func generateCompleteObsevable() -> Completable {
    
    return Completable.create { (complete) -> Disposable in
        
        let url = URL(string: "https://hbimg.huabanimg.com/f71fbce7cd0b1490679804bf98ff8092cac8f2805efe-rnEAnb_fw658")!
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            
            if error != nil {
                complete(.error(error!))
                return
            }
            
            guard let revData = data else {
                complete(.error(DataError.noData))
                return
            }
            
            UserDefaults.standard.setValue(revData, forKey: "data")
            UserDefaults.standard.synchronize()
            
            complete(.completed)
            
        })
        
        dataTask.resume()
        
        return Disposables.create { dataTask.cancel() }
    }
    
}

/// MARK: - Maybe
/// 要么发出一个元素，要么产生一个error事件，要么产生一个complete事件
func generateMaybeObservable() -> Maybe<String> {
    
    return Maybe<String>.create(subscribe: { (maybe) -> Disposable in
        
        maybe(.success("Maybe RxSwift"))
        
        // or
//        maybe(.error(DataError.Timeout))
//        maybe(.completed)
        
        return Disposables.create()
    })
}

/// MARK: - Driver



/// MARK: - Signal

