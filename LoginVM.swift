//
//  LoginVM.swift
//

import Foundation
import Combine

final class LoginVM {

    private(set) var loginConfig: FailableTextField.Configurator!
    private(set) var passwordConfig: FailableTextField.Configurator!

    private(set) var login: String?
    private(set) var password: String?

    private let service: AuthorizationServiceProtocol

    private(set) var loginResult = PassthroughSubject<AppError?, Never>()

    init(service: AuthorizationServiceProtocol) {
        self.service = service

        loginConfig = .init(
            placeholder: L10n.Common.email,
            validator: Validator.email,
            errorText: L10n.Registration.Error.email,
            onValueChange: { [weak self] text in self?.login = text }
        )
        passwordConfig = .init(
            placeholder: L10n.Registration.password,
            isSecure: true,
            onValueChange: { [weak self] text in self?.password = text }
        )
    }

    func onSignInTap() {
        guard let login = login else { return }
        guard let password = password else { return }

        service.login(email: login, password: password) { [weak self] error in
            self?.loginResult.send(error)
        }
    }
}
