//
//  SwipeBack.swift
//  SwipeTransitionExample
//
//  Created by Tatsuya Tanaka on 20180124.
//  Copyright © 2018年 tattn. All rights reserved.
//

import UIKit

final class SwipeBackNavigationController: UINavigationController {
    private let animator = SwipeBackAnimator()
    private var interactiveTransition: UIPercentDrivenInteractiveTransition!

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveTransition.completionCurve = .linear
            popViewController(animated: true)
        case .changed:
            let translation = recognizer.translation(in: view)
            interactiveTransition.update(translation.x / view.bounds.width)
        case .ended:
            if recognizer.velocity(in: view).x > 0 {
                interactiveTransition.finish()
                interactiveTransition = nil
            } else {
                fallthrough
            }
        case .cancelled:
            interactiveTransition.cancel()
            interactiveTransition = nil
        default:
            break
        }
    }
}

extension SwipeBackNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return operation == .pop ? animator : nil
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}

final class SwipeBackAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private weak var toView: UIView?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: .to),
            let from = transitionContext.viewController(forKey: .from) else { return }
        transitionContext.containerView.insertSubview(to.view, belowSubview: from.view)
        to.view.frame = transitionContext.containerView.frame
        toView = to.view

        // parallax effect
        to.view.transform.tx = -transitionContext.containerView.bounds.width * 0.3

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveLinear,
            animations: {
                to.view.transform = .identity
                from.view.transform = CGAffineTransform(translationX: to.view.frame.width, y: 0)
        }, completion: { _ in
            from.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func animationEnded(_ transitionCompleted: Bool) {
        if !transitionCompleted {
            toView?.transform = .identity
        }
    }
}
