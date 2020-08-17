//
//  SlidePresentationAnimator.swift
//  SlidePresentation
//
//  Created by chenlehui on 2020/8/17.
//

import Foundation
import UIKit

public protocol PresentationAnimator {
    var style: SlidePresentationStyle { get }
    var isPresentation: Bool { get }
    
    init(style: SlidePresentationStyle, isPresentation: Bool)
    
}

public class SlidePresentationAnimator: NSObject, PresentationAnimator {
    public var style: SlidePresentationStyle
    public var isPresentation: Bool
    weak var toViewController: UIViewController?
    weak var fromViewController: UIViewController?
    
    public required init(style: SlidePresentationStyle, isPresentation: Bool) {
        self.style = style
        self.isPresentation = isPresentation
        super.init()
    }
    
}

extension SlidePresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        toViewController = transitionContext.viewController(forKey:  UITransitionContextViewControllerKey.to)
        toViewController?.beginAppearanceTransition(true, animated: true)
        
        fromViewController = transitionContext.viewController(forKey:  UITransitionContextViewControllerKey.from)
        
        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        let width = transitionContext.containerView.frame.width
        let height = transitionContext.containerView.frame.height
        switch style {
        case .actionSheet(.top), .alert(.top):
            dismissedFrame.origin.y = -presentedFrame.height
        case .actionSheet(.left), .alert(.left):
            dismissedFrame.origin.x = -presentedFrame.width
        case .actionSheet(.bottom), .alert(.bottom):
            dismissedFrame.origin.y = height
        case .actionSheet(.right), .alert(.right):
            dismissedFrame.origin.x = width
        }
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        var finalFrame = isPresentation ? presentedFrame : dismissedFrame
        let duration = transitionDuration(using: transitionContext)
        
        switch style {
        case .alert(.top):
            finalFrame.origin.y = height
        case .alert(.left):
            finalFrame.origin.x = width
        case .alert(.bottom):
            finalFrame.origin.y = -presentedFrame.height
        case .alert(.right):
            finalFrame.origin.x = -presentedFrame.width
        default:
            break
        }

        controller.view.frame = initialFrame
        UIView.animate(withDuration: duration, animations: {
            controller.view.frame = finalFrame
        }) { (isFinished) in
            transitionContext.completeTransition(isFinished)
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool){
        if transitionCompleted {
            toViewController?.endAppearanceTransition()
        }
    }
}
