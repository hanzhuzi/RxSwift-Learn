//
//  SearchViewController.swift
//  RxSwift01
//
//  Created by 徐冉 on 2019/9/20.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var imageVw: UIImageView!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let observer: AnyObserver<String> = AnyObserver<String> { [unowned self](event) in
            switch event {
            case .next(let text):
                print("text->\(text)")
                self.countLbl.text = "\(text.count)"
                break
            default:
                break
            }
        }
        
        searchBar.rx.text.orEmpty
            .subscribe(observer)
        .disposed(by: disposeBag)
        
        let imageObservable = Observable<UIImage>.create { (observer) -> Disposable in
            
            print(Thread.current)
            
            let data = try? Data(contentsOf: URL(string: "http://img.wmzhe.top/contents/7b/39/7b39357dfe5343e85643dc082fe88918.png")!)
            
            if data != nil {
                observer.onNext(UIImage(data: data!)!)
            }
            else {
                observer.onError(DataError.noData)
            }
            
            return Disposables.create()
        }
        .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        imageObservable
            .observeOn(MainScheduler.instance)
            .bind(to: imageVw.rx.image)
        .disposed(by: disposeBag)
        
        imageObservable.subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (image) in
                print("data length->\(image.pngData()!.count)")
            }, onError: { (error) in
                print("err->\(error)")
            }, onCompleted: {
                
            }, onDisposed: nil)
        .disposed(by: disposeBag)
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
