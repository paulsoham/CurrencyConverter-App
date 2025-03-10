//
//  CurrencyViewController.swift
//  CurrencyConverter
//
//  Created by SOHAM PAUL on 26/01/25.
//

import UIKit
import Combine

class CurrencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let viewModel: CurrencyViewModel
    private var convertedRates: [String: Double] = [:]
    private var cancellables: [AnyCancellable] = []
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("enterAmount", comment: "Placeholder text for amount text field")
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.tag = 1
        textField.font = UIFont(name: "OpenSans-Regular", size: 15)
        textField.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return textField
    }()
    
    private lazy var currencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("usdButtonTitle", comment: "Title for currency button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(currencyButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 18)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.tag = 2
        return button
    }()
    
    private lazy var currencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isHidden = true
        picker.tag = 3
        return picker
    }()
    
    private lazy var conversionGrid: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width - 40) / 3 - 10, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.tag = 4
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.tag = 5
        return activityIndicator
    }()
    
    private var gridTopConstraint: NSLayoutConstraint!
    private var pickerTopConstraint: NSLayoutConstraint!
    
    init(viewModel: CurrencyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let apiService = APIService()
        let persistenceService = PersistenceService()
        self.viewModel = CurrencyViewModel(apiService: apiService, persistenceService: persistenceService)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        viewModel.fetchExchangeRates()
    }
    // MARK: - Setup UI
    private func setupUI() {
        setupActivityIndicator()
        setupAmountTextField()
        setupCurrencyButton()
        setupCurrencyPicker()
        setupConversionGrid()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupAmountTextField() {
        view.addSubview(amountTextField)
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCurrencyButton() {
        view.addSubview(currencyButton)
        NSLayoutConstraint.activate([
            currencyButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 10),
            currencyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCurrencyPicker() {
        view.addSubview(currencyPicker)
        pickerTopConstraint = currencyPicker.topAnchor.constraint(equalTo: currencyButton.bottomAnchor, constant: 10)
        NSLayoutConstraint.activate([
            pickerTopConstraint,
            currencyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currencyPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupConversionGrid() {
        view.addSubview(conversionGrid)
        gridTopConstraint = conversionGrid.topAnchor.constraint(equalTo: currencyButton.bottomAnchor, constant: 20)
        NSLayoutConstraint.activate([
            gridTopConstraint,
            conversionGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            conversionGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            conversionGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        
        viewModel.$exchangeRates
            .sink { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    self?.conversionGrid.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$baseCurrency
            .sink { [weak self] baseCurrency in
                self?.currencyButton.setTitle("\(baseCurrency) ▼", for: .normal)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                DispatchQueue.main.async { [weak self] in
                    if isLoading {
                        self?.activityIndicator.startAnimating()
                    } else {
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Currency Button Action
    @objc func currencyButtonTapped() {
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            showAlert(message: NSLocalizedString("errorMessageAmount", comment: "Error message when amount is empty"))
            return
        }
        guard let amount = Double(amountText), amount != 0 else {
            showAlert(message: NSLocalizedString("errorMessageZeroAmount", comment: "Error message when amount is zero"))
            return
        }
        guard !viewModel.exchangeRates.isEmpty else {
            showAlert(message: NSLocalizedString("errorMessageNoRates", comment: "Error message when exchange rates are unavailable"))
            return
        }
        currencyPicker.isHidden.toggle()
        gridTopConstraint.constant = currencyPicker.isHidden ? 20 : 160
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        currencyPicker.reloadAllComponents()
        
        let selectedCurrency = viewModel.baseCurrency
        let targetCurrencies = viewModel.exchangeRates.keys.joined(separator: ",")
        convertedRates = viewModel.convert(amount: amount, from: selectedCurrency, to: targetCurrencies)
        DispatchQueue.main.async { [weak self] in
            self?.conversionGrid.reloadData()
        }
    }
    
    // MARK: - Show Alert
    func showAlert(message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("errorMessage", comment: "Alert title for error messages"), message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("okButton", comment: "Title for OK button in alert"), style: .default)
        alertController.addAction(okayAction)
        present(alertController, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        return allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    // MARK: - UIPickerView Delegate and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.exchangeRates.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(viewModel.exchangeRates.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = Array(viewModel.exchangeRates.keys)[row]
        viewModel.baseCurrency = selectedCurrency 
        
        currencyButton.setTitle("\(selectedCurrency) ▼", for: .normal)
        currencyPicker.isHidden = true
        gridTopConstraint.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        guard let text = amountTextField.text, let amount = Double(text) else {
            convertedRates = [:]
            DispatchQueue.main.async { [weak self] in
                self?.conversionGrid.reloadData()
            }
            return
        }
        
        convertedRates = viewModel.convert(amount: amount, from: selectedCurrency, to: viewModel.exchangeRates.keys.joined(separator: ","))
        DispatchQueue.main.async { [weak self] in
            self?.conversionGrid.reloadData()
        }
    }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.exchangeRates.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1.0
        cell.backgroundColor = .white
        
        for subview in cell.contentView.subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        let currency = Array(viewModel.exchangeRates.keys)[indexPath.row]
        let rate = convertedRates[currency] ?? 0.0
        
        // MARK: - Label in Collectionview cell
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "OpenSans-Regular", size: 12)
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        
        let attributedText = NSMutableAttributedString(string: "\(currency)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedText.append(NSAttributedString(string: String(format: "%.2f", rate), attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        
        cell.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5),
            label.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5)
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 40) / 3 - 10, height: 100)
    }
}
