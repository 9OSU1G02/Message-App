//
//  OnboardViewController.swift
//  Message App
//
//  Created by Nguyen Quoc Huy on 11/2/20.
//

import UIKit
import paper_onboarding
//Only CLASS can conform to this protocol
protocol OnboardingController: AnyObject {
    func controllerWantToDismiss(_ controller: OnboardingViewController)
}
class OnboardingViewController: UIViewController {
    
    // MARK:  Properties
    weak var delegate: OnboardingController?
    private var onboardingItems = [OnboardingItemInfo]()
    private var onboarding = PaperOnboarding()
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(ONBOARDING_BUTTON_TITLE, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissOnboarding), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.alpha = 0
        return button
    }()
    
    // MARK:  Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureOnboardingDataSource()
        onboarding.dataSource = self
        onboarding.delegate = self
        configureUI()
        
    }
    
    // MARK:  Selectors
    
    @objc func dismissOnboarding() {
        delegate?.controllerWantToDismiss(self)
    }
    
    // MARK:  Helpers
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func animateGetStartedButton(_ shouldShow: Bool) {
        let alpha: CGFloat = shouldShow ? 1 : 0
        UIView.animate(withDuration: 0.5) {
            self.getStartedButton.alpha = alpha
        }
    }
    
    func configureUI() {
                        
        //ONbarding config
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
        
        //getStartedButton config
        view.addSubview(getStartedButton)
        getStartedButton.centerX(inView: view)
        getStartedButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 128)
    }
    
    func configureOnboardingDataSource() {
        let item1 = OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "time"), title: MSG_TIME, description: MSG_ONBOARDING_TIME, pageIcon: UIImage(), color: .systemPink, titleColor: .white, descriptionColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 24), descriptionFont: UIFont.boldSystemFont(ofSize: 16))
        let item2 = OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "house"), title: MSG_HOUSE, description: MSG_ONBOARDING_HOUSE, pageIcon: UIImage(), color: .purple, titleColor: .white, descriptionColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 24), descriptionFont: UIFont.boldSystemFont(ofSize: 16))
        let item3 = OnboardingItemInfo(informationImage: #imageLiteral(resourceName: "business"), title: MSG_BUSINESS, description: MSG_ONBOARDING_BUSINESS, pageIcon: UIImage(), color: .blue, titleColor: .white, descriptionColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 24), descriptionFont: UIFont.boldSystemFont(ofSize: 16))
        onboardingItems.append(item1)
        onboardingItems.append(item2)
        onboardingItems.append(item3)
    }
    func shouldShowGetStartedButton(forIndex index: Int) -> Bool {
        return index == onboardingItems.count - 1 ? true : false
    }
}

// MARK:  Extension & Delegate

//Work same like tableView (trigger for every Onboarding)
extension OnboardingViewController: PaperOnboardingDataSource {
    func onboardingItemsCount() -> Int {
        onboardingItems.count
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        onboardingItems[index]
    }
}

//Work same like tableView (trigger for every Onboarding)
extension OnboardingViewController: PaperOnboardingDelegate {
    func onboardingWillTransitonToIndex(_ index: Int) {
        let shouldShow = shouldShowGetStartedButton(forIndex: index)
       animateGetStartedButton(shouldShow)
    }
}
