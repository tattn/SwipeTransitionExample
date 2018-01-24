//
//  SwipeToDismiss.swift
//  SwipeTransitionExample
//
//  Created by Tatsuya Tanaka on 20180124.
//  Copyright © 2018年 tattn. All rights reserved.
//

import UIKit

final class SwipeToDismissNaviagtionController: UINavigationController {
    private let animator = SwipeToDismissAnimator()
    private var interactiveTransition: UIPercentDrivenInteractiveTransition!

    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self

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
            dismiss(animated: true, completion: nil)
        case .changed:
            let translation = recognizer.translation(in: view)
            interactiveTransition.update(translation.y / view.bounds.height)
        case .ended:
            if interactiveTransition!.percentComplete > 0.3 {
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

extension SwipeToDismissNaviagtionController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeToDismissAnimator()
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}

final class SwipeToDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.viewController(forKey: .from) else { return }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveLinear,
            animations: {
                from.view.transform = CGAffineTransform(translationX: 0, y: from.view.frame.height)
        }, completion: { _ in
            from.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func animationEnded(_ transitionCompleted: Bool) {
    }
}
