//
//  LoginVC.swift
//

import Foundation
import Combine
import UIKit
import SnapKit

final class LoginVC: ViewController {

    private var loginField: FailableTextField!
    private var passwordField: FailableTextField!

    private var loginButton: UIButton!
    private var forgotPassButton: UIButton!
    private var registerButton: UIButton!

    private var termsAndPolicyView: TermsAndPolicyView!

    private let viewModel: LoginVM
    private weak var router: LoginRouter?

    private var loginStream: AnyCancellable?

    init(router: LoginRouter) {
        self.router = router
        self.viewModel = LoginVM(service: AuthorizationService.make())
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        loginStream = viewModel.loginResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                if let error = error {
                    self?.router?.showError(error)
                } else {
                    self?.router?.onLoginSuccess()
                }
            })
    }

    func setupViews() {
        passwordField = FailableTextField(config: viewModel.passwordConfig)
        view.addSubview(passwordField)

        loginField = FailableTextField(config: viewModel.loginConfig)
        view.addSubview(loginField)

        loginButton = PrimaryButton(title: L10n.Login.login)
        view.addSubview(loginButton)

        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

        forgotPassButton = BasicButton(title: L10n.Login.recoveryPassword)
        view.addSubview(forgotPassButton)

        forgotPassButton.addTarget(self, action: #selector(didTapRecoveryButton), for: .touchUpInside)

        registerButton = BasicButton(title: L10n.Login.signUp)
        view.addSubview(registerButton)

        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)

        termsAndPolicyView = TermsAndPolicyView()
        termsAndPolicyView.delegate = self
        view.addSubview(termsAndPolicyView)

        snapSubviews()
    }

    func snapSubviews() {
        passwordField.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.snp.centerY)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        loginField.snp.makeConstraints { make in
            make.bottom.equalTo(passwordField.snp.top)
            make.width.centerX.equalTo(passwordField)
        }
        loginButton.snp.makeConstraints { make in
            make.centerX.equalTo(passwordField)
            make.top.equalTo(passwordField.snp.bottom).offset(12)
        }
        forgotPassButton.snp.makeConstraints { make in
            make.width.centerX.equalTo(passwordField)
            make.top.equalTo(loginButton.snp.bottom).offset(16)
        }
        registerButton.snp.makeConstraints { make in
            make.width.centerX.equalTo(passwordField)
            make.top.equalTo(forgotPassButton.snp.bottom).offset(16)
        }
        termsAndPolicyView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.centerX.equalTo(passwordField)
        }
    }

    @objc
    private func didTapRegisterButton() {
        view.endEditing(true)
        router?.onSignUp(email: viewModel.login)
    }

    @objc
    private func didTapLoginButton() {
        view.endEditing(true)
        viewModel.onSignInTap()
    }

    @objc
    private func didTapRecoveryButton() {
        view.endEditing(true)
        router?.onRecoverPassword(email: viewModel.login)
    }
}

extension LoginVC: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        debugPrint(URL)

        return true
    }
}
