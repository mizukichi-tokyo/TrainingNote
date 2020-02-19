//
//  AlertRxExtension.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/19.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public func alert(title: String?, message: String?) -> AlertController {
    return AlertController(title: title, message: message, preferredStyle: .alert)
}

public func actionSheet(title: String?, message: String?) -> AlertController {
    return AlertController(title: title, message: message, preferredStyle: .actionSheet)
}

public class AlertController: NSObject {

    public struct Result {
        public let buttonIndex: Int
        public let buttonTitle: String
        public let controller: UIAlertController

        init(alert: UIAlertController, buttonTitle: String, buttonIndex: Int) {
            self.buttonTitle = buttonTitle
            self.buttonIndex = buttonIndex
            controller  = alert
        }
    }

    internal  let alertController: UIAlertController
    internal var observer: AnyObserver<Result>?
    private  var retainSelf: Any?
    private  let disposeBag = DisposeBag()

    init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
        alertController = .init(title:title, message:message, preferredStyle:preferredStyle)

        super.init()

        alertController.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.microseconds(300)) {
                    self?.retainSelf = nil
                }
            })
            .disposed(by: disposeBag)

        retainSelf = self
    }

    public func addAction(title: String, style: UIAlertAction.Style = .default,
                          configure: ((UIAlertController, UIAlertAction) -> Void)? = nil) -> Self {
        let action = UIAlertAction(title: title, style: style) { [unowned self] action in

            let result = Result(alert: self.alertController, buttonTitle: title,
                                buttonIndex: self.alertController.actions.firstIndex(of: action) ?? 0)

            self.observer?.onNext(result)
            self.observer?.onCompleted()
        }
        alertController.addAction(action)
        configure?(alertController, action)

        return self
    }

    public func addPreferredAction(title: String, style: UIAlertAction.Style = .default,
                                   configure: ((UIAlertController, UIAlertAction) -> Void)? = nil) -> Self {
        return addAction(title: title, style: style) { alertController, action in
            alertController.preferredAction = action
            configure?(alertController, action)
        }
    }

    public func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) -> Self {
        alertController.addTextField(configurationHandler: configurationHandler)

        return self
    }

    @discardableResult
    public func show(animated: Bool = true, completion: (() -> Void)? = nil) -> Self {
        if alertController.preferredStyle == .actionSheet &&
            UIDevice.current.userInterfaceIdiom == .pad {
            if let popOver = alertController.popoverPresentationController {
                if popOver.sourceView == nil {
                    if let topVC = self.topViewController {
                        popOver.sourceView = topVC.view
                        popOver.sourceRect = CGRect(x: topVC.view.bounds.midX,
                                                    y: topVC.view.bounds.midY,
                                                    width: 0,
                                                    height: 0)

                        popOver.permittedArrowDirections = []
                    }
                }
            }
        }

        self.presentedController?.present(self.alertController,
                                          animated: animated,
                                          completion: completion)

        return self
    }

    private var presentedController: UIViewController? {

        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first

        if let viewController = keyWindow?.rootViewController {
            //Find the presented view controller
            var presentedController = viewController

            while presentedController.presentedViewController != nil &&
                presentedController.presentedViewController?.isBeingDismissed == false {
                    presentedController = presentedController.presentedViewController!
            }

            return presentedController
        }

        return nil
    }

    private var topViewController: UIViewController? {
        var topController = self.presentedController

        while topController?.children.last != nil {
            topController = topController?.children.last!
        }

        return topController
    }

    /// For ActionSheet
    public func setBarButton(item: UIBarButtonItem) -> Self {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return self
        }

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = item
        }

        return self
    }

    /// For ActionSheet
    public func setPresenting(source: UIView) -> Self {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return self
        }

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = source
            popoverController.sourceRect = source.bounds
            popoverController.permittedArrowDirections = [.any]
        }

        return self
    }

    deinit {
        //print("deinit")
    }
}

public extension Reactive where Base: AlertController {
    func show(animated: Bool = true, completion: (() -> Void)? = nil) -> Observable<AlertController.Result> {
        self.base.show(animated: animated, completion: completion)

        return Observable.create { observer in
            self.base.observer = observer

            return Disposables.create()
        }
    }
}
