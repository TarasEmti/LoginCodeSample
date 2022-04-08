//
//  Router.swift
//

import Foundation
import UIKit

protocol Routable: Presentable {

    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)

    func push(_ module: Presentable?)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, style: CATransitionType)

    func popModule()
    func popModule(animated: Bool)

    func dismissModule()
    func dismissModule(animated: Bool, completion: CompletionBlock?)

    func setRootModule(_ module: Presentable?, hideBar: Bool)

    func popToRootModule(animated: Bool)

    func becomeNavigationDelegate(_ delegate: UINavigationControllerDelegate)
}

final class Router: Routable {

    var toPresent: UIViewController? {
        return rootController
    }

    private let rootController: UINavigationController

    init(rootController: UINavigationController) {
        self.rootController = rootController
    }

    func becomeNavigationDelegate(_ delegate: UINavigationControllerDelegate) {
        rootController.delegate = delegate
    }

    func present(_ module: Presentable?) {
        present(module, animated: true)
    }

    func present(_ module: Presentable?, animated: Bool) {
        guard let presentable = module?.toPresent else { return }
        rootController.present(presentable, animated: animated, completion: nil)
    }

    func push(_ module: Presentable?) {
        push(module, animated: true)
    }

    func push(_ module: Presentable?, animated: Bool) {
        guard let presentable = module?.toPresent else { return }
        rootController.pushViewController(presentable, animated: animated)
    }

    func push(_ module: Presentable?, style: CATransitionType) {
        let transition = CATransition()
        transition.type = style
        rootController.view.layer.add(transition, forKey: nil)
        push(module, animated: false)
    }

    func popModule() {
        popModule(animated: true)
    }

    func popModule(animated: Bool) {
        rootController.popViewController(animated: animated)
    }

    func dismissModule() {
        dismissModule(animated: true, completion: nil)
    }

    func dismissModule(animated: Bool, completion: CompletionBlock?) {
        rootController.dismiss(animated: animated, completion: completion)
    }

    func setRootModule(_ module: Presentable?, hideBar: Bool) {
        guard let presentable = module?.toPresent else { return }
        rootController.setViewControllers([presentable], animated: true)
        rootController.isNavigationBarHidden = hideBar
    }

    func popToRootModule(animated: Bool) {
        rootController.popToRootViewController(animated: animated)
    }
}
