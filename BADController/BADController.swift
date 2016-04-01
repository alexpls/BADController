//
//  BADController.swift
//  BADController
//
//  Created by Alex Plescan on 1/02/2016.
//  Copyright © 2016 Alex Plescan. All rights reserved.
//

import UIKit
import GoogleMobileAds

typealias DeviceAdId = String

enum AdPlacement {
    case Bottom
}

public struct BADControllerOptions {
    let testDevices: [DeviceAdId] = [
        (kGADSimulatorID as! String)
    ]
    
    let placement: AdPlacement = .Bottom
    
    let displayAds: Bool = true
    
    let adUnitId: String
}

public class BADController: UIViewController {
    var containerView: UIView!
    private var googleAdView: GADBannerView!
    
    private var containerToAdConstraint: NSLayoutConstraint?
    private var containerToBottomConstraint: NSLayoutConstraint!
    
    var statusBarStyle: UIStatusBarStyle = .Default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    var options: BADControllerOptions!
    
    override public func viewDidLoad() {
        containerView = UIView()
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        containerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        containerView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        containerToBottomConstraint = containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        containerToBottomConstraint.active = true
        
        configBannerView()
    }
    
    func configBannerView() {
        guard options.displayAds else { return }
        
        googleAdView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        googleAdView.adUnitID = options.adUnitId
        googleAdView.rootViewController = self
        googleAdView.delegate = self
        googleAdView.hidden = true
        
        let request = GADRequest()
        request.testDevices = options.testDevices
        googleAdView.loadRequest(request)
        
        view.addSubview(googleAdView)
        
        googleAdView.translatesAutoresizingMaskIntoConstraints = false
        googleAdView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        googleAdView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        googleAdView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        containerToAdConstraint = containerView.bottomAnchor.constraintEqualToAnchor(googleAdView.topAnchor)
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }
    
}

extension BADController: GADBannerViewDelegate {
    public func adViewDidReceiveAd(bannerView: GADBannerView!) {
        if let banner = googleAdView where bannerView == googleAdView {
            banner.transform = CGAffineTransformMakeTranslation(0, banner.bounds.height)
            
            banner.hidden = false
            
            UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: [], animations: { () -> Void in
                banner.transform = CGAffineTransformIdentity
                }, completion: { (complete) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.containerToAdConstraint?.active = true
                        self.containerToBottomConstraint.active = false
                    }
            })
        }
    }
    
    public func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        containerToAdConstraint?.active = false
        containerToBottomConstraint.active = true
    }
}