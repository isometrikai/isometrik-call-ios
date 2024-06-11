//
//  ISMLKLoader.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 23/09/23.
//

import Foundation
import UIKit

class CustomAPIIndicatorView: UIView {
    
    private let activityIndicatorView: UIActivityIndicatorView
    
    init() {
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        super.init(frame: .zero)
        
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(activityIndicatorView)
        
        // Customize the appearance of your indicator view here
        activityIndicatorView.color = .white
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        activityIndicatorView.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }
}


class ISMShowLoader {
    
    
    static let sharerd = ISMShowLoader()
    
    private var customAPIIndicatorView: CustomAPIIndicatorView?
    private var topMostViewController: UIViewController?
    
    init(){
        self.updateTopMostController()
        customAPIIndicatorView = CustomAPIIndicatorView()
        customAPIIndicatorView?.frame = topMostViewController?.view.bounds ?? .zero
        customAPIIndicatorView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        topMostViewController?.view.addSubview(customAPIIndicatorView!)
        
    }
    
    
    // To start the indicator
    func startLoading() {
        DispatchQueue.main.async {
            self.updateTopMostController()
            self.customAPIIndicatorView?.startAnimating()
            self.topMostViewController?.view.addSubview(self.customAPIIndicatorView!)
        }
        
    }
    
    // To stop the indicator
    func stopLoading() {
        DispatchQueue.main.async {
            self.customAPIIndicatorView?.stopAnimating()
            self.customAPIIndicatorView?.removeFromSuperview()
        }
    }
    
    
    func updateTopMostController(){
        
        if let rootViewController = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first?.rootViewController {
            self.topMostViewController = rootViewController
        }
        while let presentedViewController = topMostViewController?.presentedViewController {
            self.topMostViewController =  presentedViewController
        }
        
    }
    
}


class ISMLiveKitCallUtil{
    
    static func topPresentedController() -> UIViewController?  {

            
            
            var topMostViewController : UIViewController? = nil
            
            if let rootViewController = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first?.rootViewController {
                topMostViewController = rootViewController
            }
            while let presentedViewController = topMostViewController?.presentedViewController {
                topMostViewController =  presentedViewController
            }
            return topMostViewController
        
    }
}
