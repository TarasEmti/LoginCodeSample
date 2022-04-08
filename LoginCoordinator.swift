//
//  LoginCoordinator.swift
//

import Foundation
import UIKit

protocol LoginRouter: ErrorPresentable {

    func onLoginSuccess()
    func onSignUp(email: String?)
    func onRecoverPassword(email: String?)
}

final class LoginCoordinator: BaseCoordinator, Coordinating {

    var finishFlow: CompletionBlock?

    private let factory: CoordinatorsFactoryProtocol
    let router: Routable

    init(factory: CoordinatorsFactoryProtocol, router: Routable) {
        self.router = router
        self.factory = factory
        super.init()
        router.becomeNavigationDelegate(self)
    }

    func start() {
        let loginView = LoginVC(router: self)
        router.setRootModule(loginView, hideBar: false)
    }
}

extension LoginCoordinator: CoordinatorNavigating {

    func onLeave(controller: UIViewController) {
        if controller is LoginVC {
            finishFlow?()
        }
    }

    func navigationController(
        _ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool
    ) {
        guard let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        guard !navigationController.viewControllers.contains(fromVC) else { return }
        onLeave(controller: fromVC)
    }
}

extension LoginCoordinator: LoginRouter {

    func onLoginSuccess() {
        UserAuthorization.shared.status = .logged
    }

    func onSignUp(email: String?) {
        let coordinator = factory.registrationCoordinator(with: router, data: email)
        coordinator.finishFlow = { [unowned self, unowned coordinator] in
            self.removeChild(coordinator)
        }
        addChild(coordinator)
        coordinator.start()
    }

    func onRecoverPassword(email: String?) {
        let view = RecoveryVC(router: self, email: email)
        router.push(view)
    }
}

extension LoginCoordinator: RecoveryRouter {

    func onRecoverySuccess() {
        router.popModule()
    }
}
