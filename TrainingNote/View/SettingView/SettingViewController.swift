//
//  SettingViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SettingViewController: UIViewController, Injectable {
    typealias Dependency = SettingViewModel

    @IBOutlet private weak var tableView: UITableView!

    @IBAction func plusButton() {
        alert(title: "Test", message: "This is a test message.")
            .addAction(title: "Yes")
            .addAction(title: "No", style: .destructive)
            .addTextField {
                $0.placeholder = "placeholder"
        }
        .rx.show()
        .subscribe(onNext: {
            print("button: \($0.buttonTitle)")
            print($0.controller.textFields?.first?.text ?? "")
        })
            .disposed(by: disposeBag)
    }

    @IBAction func moveToCalender(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionOfExerciseData>!
    private let viewModel: SettingViewModel

    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupViewModel()

    }

    func setupViewModel() {

        let input = SettingViewModelInput(
            swipeCell: tableView.rx.itemDeleted
        )

        viewModel.setup(input: input)

        viewModel.outputs?.sectionDataDriver
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}

extension SettingViewController {

    private func setupTableView() {
        registerTableViewCell()
        setupDataSource()
    }

    private func registerTableViewCell() {
        tableView.register(
            SettingTableViewCell.self,
            forCellReuseIdentifier: R.reuseIdentifier.settingTableViewCell.identifier
        )
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfExerciseData>(
            configureCell: { ( _, tableView: UITableView, indexPath: IndexPath, model: ExerciseData
                ) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: R.reuseIdentifier.settingTableViewCell.identifier,
                    for: indexPath
                )
                cell.textLabel?.text = model.exerciseName
                return cell
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })
    }

}

extension SettingViewController {
    static func makeVC () -> SettingViewController {
        let viewModel = SettingViewModel(with: SettingViewModel.Dependency.init())
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}

@available(iOS 8.0, *)
public func alert(title: String?, message: String?) -> AlertController {
    return AlertController(title: title, message: message, preferredStyle: .alert)
}

@available(iOS 8.0, *)
public func actionSheet(title: String?, message: String?) -> AlertController {
    return AlertController(title: title, message: message, preferredStyle: .actionSheet)
}

@available(iOS 8.0, *)
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

    @available(iOS 9.0, *)
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
