//
//  ViewController.swift
//  RxSwift01
//
//  Created by 徐冉 on 2019/9/18.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var phoneMinderLbl: UILabel!
    @IBOutlet weak var pwdMinderLbl: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        phoneTF.layer.masksToBounds = true
        phoneTF.layer.cornerRadius = 19
        phoneTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        phoneTF.leftViewMode = .always
        
        passwordTF.layer.masksToBounds = true
        passwordTF.layer.cornerRadius = 19
        passwordTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        passwordTF.leftViewMode = .always
        
        passwordTF.isEnabled = false
        loginBtn.isEnabled = false
        
        // 订阅序列
        let phoneNumValidObserve = phoneTF.rx.text.orEmpty
            .map { $0.count >= 11 }
            .share(replay: 1)
        
        // 绑定订阅者
        phoneNumValidObserve.bind(to: passwordTF.rx.isEnabled)
        .disposed(by: disposeBag)
        
        phoneNumValidObserve.bind(to: phoneMinderLbl.rx.isHidden)
        .disposed(by: disposeBag)
        
        let pwdValidObserve = passwordTF.rx.text.orEmpty
            .map { $0.count >= 6 }
            .share(replay: 1)
        
        pwdValidObserve.bind(to: pwdMinderLbl.rx.isHidden)
        .disposed(by: disposeBag)
        
        phoneTF.rx.text.orEmpty.subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { (text) in
            print("phone->\(text)")
        }, onError: { (_) in
            
        }, onCompleted: {
            
        }, onDisposed: nil)
        .disposed(by: disposeBag)
        
        loginBtn.rx.tap.subscribe(onNext: { (event) in
            print("Login tapped!!")
        })
        .disposed(by: disposeBag)
        
        // Combine
        let allValidObserable = Observable.combineLatest(phoneNumValidObserve, pwdValidObserve, resultSelector: { $0 && $1 }).share(replay: 1)
        
        allValidObserable.bind(to: loginBtn.rx.isEnabled)
        .disposed(by: disposeBag)
        
        // 创建可观察序列
        self.createObservables()
        
    }

    
}

/// MARK: - Observable Creates
extension ViewController {
    
    // 创建可监听序列
    func createObservables() {
        
        // Observable
        generateObservaleSequece().subscribe(onNext: { (str) in
            print("Observable: \(str)")
        }, onError: { (_) in
            
        }, onCompleted: {
            print("Observable: Complete！")
        }, onDisposed: nil)
        .disposed(by: disposeBag)
        
        // Single
        getRepos("RxSwift").subscribe(onSuccess: { (dict) in
            print("获取成功->\(dict)")
        }) { (error) in
            print("获取失败err->\(error)")
        }
        .disposed(by: disposeBag)
        
        // Completable
        generateCompleteObsevable().subscribe(onCompleted: {
            print("下载完成！")
        }) { (error) in
            print("下载出错err->\(error)")
        }
        .disposed(by: disposeBag)
        
        // Maybe
        generateMaybeObservable().subscribe(onSuccess: { (str) in
            print("Maybe: \(str)")
        }, onError: { (_) in
            
        }) {
            print("Maybe: complete!")
        }
        .disposed(by: disposeBag)
        
        
        
    }

}

