//
//  FailableTextField.swift
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class FailableTextField: UIView {

    private let decorator: Decorating?
    private let validator: String.Validator?

    var textField: UITextField!
    private var placeholderLabel: UILabel!
    private var errorLabel: UILabel!
    private var botBorder: UIView!

    private var callback: ((String) -> Void)?

    init(config: Configurator) {
        decorator = config.decorator
        validator = config.validator
        callback = config.onValueChange

        super.init(frame: .zero)

        config.onForceValidate = { [unowned self] in
            guard let text = self.textField.text else { return }
            self.checkValue(text)
        }

        textField = UITextField()
        textField.delegate = self
        textField.keyboardType = config.kbType ?? .default
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = config.isSecure

        botBorder = UIView()

        errorLabel = UILabel()
        errorLabel.font = .systemFont(ofSize: 12)
        errorLabel.textColor = .red
        errorLabel.text = config.errorText
        errorLabel.numberOfLines = 0
        errorLabel.sizeToFit()

        placeholderLabel = UILabel()
        placeholderLabel.font = .systemFont(ofSize: 12)
        placeholderLabel.textColor = .gray
        placeholderLabel.text = config.placeholder

        addSubview(textField)
        addSubview(botBorder)
        addSubview(errorLabel)
        addSubview(placeholderLabel)

        if let text = config.value, !text.isEmpty {
            textField.text = decorator?.maskedFrom(string: text) ?? text
        }
        validState()
        snapSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func snapSubviews() {
        let vMargin = errorLabel.font.lineHeight + 6

        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(vMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        botBorder.snp.makeConstraints { make in
            make.leading.trailing.equalTo(textField)
            make.top.equalTo(textField.snp.bottom).offset(2)
            make.height.equalTo(1)
        }

        errorLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField)
            make.trailing.equalTo(textField)
            make.top.equalTo(textField.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(textField)
            make.bottom.equalTo(textField.snp.top)
        }
    }

    private func checkValue(_ text: String) {
        let decorated = decorator == nil ? text : decorator!.stringFrom(masked: text)
        let textIsValid = validator == nil ? true : validator!(decorated)

        if textIsValid {
            validState()
            callback?(decorated)
        } else {
            errorState()
            callback?("")
        }
    }

    func errorState() {
        botBorder.backgroundColor = UIColor.red
        errorLabel.isHidden = false
    }

    func validState() {
        botBorder.backgroundColor = UIColor.lightGray
        errorLabel.isHidden = true
    }
}

extension FailableTextField: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return false }
        guard let decorator = decorator else { return true }
        let input = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = decorator.maskedFrom(string: input)

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            validState()
            return
        }
        checkValue(text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if IQKeyboardManager.shared.canGoNext {
            IQKeyboardManager.shared.goNext()
        }
        return true
    }
}

extension FailableTextField {

    final class Configurator: Configurate {

        let value: String?
        let placeholder: String
        let kbType: UIKeyboardType?
        let isSecure: Bool
        let validator: String.Validator?
        let decorator: Decorating?
        let errorText: String?
        let onValueChange: ((String) -> Void)?
        fileprivate var onForceValidate: (() -> Void)?

        let cellType: TableViewCell.Type

        init(
            placeholder: String,
            value: String? = nil,
            kbType: UIKeyboardType = .default,
            isSecure: Bool = false,
            validator: String.Validator? = nil,
            decorator: Decorating? = nil,
            errorText: String? = nil,
            onValueChange: ((String) -> Void)? = nil,
            cellType: TableViewCell.Type = FailableTextCell.self
        ) {
            self.value = value
            self.placeholder = placeholder
            self.kbType = kbType
            self.isSecure = isSecure
            self.decorator = decorator
            self.validator = validator
            self.errorText = errorText
            self.onValueChange = onValueChange
            self.cellType = cellType
        }

        func forceValidate() {
            onForceValidate?()
        }
    }
}
