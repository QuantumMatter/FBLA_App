//
//  TransitionOperator.m
//  App Of Life
//
//  Created by David Kopala on 12/23/14.
//  Copyright (c) 2014 David Kopala. All rights reserved.
//

#import "TransitionOperator.h"

#define right @"slideRight"


@interface TransitionOperator ()

@end

@implementation TransitionOperator {
    UIView *snapshot;
    BOOL isPresenting;
}

-(CGFloat) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

-(void) animateTransition:(UIView<UIViewControllerContextTransitioning> *)transitionContext {
    NSLog(@"Animate Transmition");
    if (isPresenting) {
        [self presentAnimation:transitionContext];
    } else {
        [self dismissAnimation:transitionContext];
    }
}

-(void) presentAnimation:(UIView<UIViewControllerContextTransitioning> *)transitionContext {
    NSLog(@"Called TransitionOperator.presentAnimation");
    UIViewController *toViewController = [[UIViewController alloc] init];
    toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [[UIView alloc] init];
    toView = toViewController.view;
    
    UIViewController *fromViewController = [[UIViewController alloc] init];
    fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [[UIView alloc] init];
    fromView = fromViewController.view;
    
    CGSize size = toView.frame.size;
    CGAffineTransform offsetTransformation = CGAffineTransformMakeTranslation(size.width - 120, 0);
    
    snapshot = [[UIView alloc] init];
    snapshot = [fromView snapshotViewAfterScreenUpdates:true];
    
    UIView *container = [[UIView alloc] init];
    container = transitionContext.containerView;
    toView.userInteractionEnabled = YES;
    [container addSubview:toView];
    [container addSubview:snapshot];
    
    CGFloat duration = [self transitionDuration:transitionContext];
   
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{snapshot.transform = offsetTransformation;}
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:finished];
                         NSLog(@"Finished Transition");
                     }];
}

-(void) dismissAnimation:(UIView<UIViewControllerContextTransitioning> *)transitionContext {
    CGFloat duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         snapshot.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         [transitionContext completeTransition:finished];
                         NSLog(@"Finsished Transition");
                         [snapshot removeFromSuperview];
                     }];
}

-(id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    isPresenting = true;
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed {
    isPresenting = false;
    return self;
}

@end
