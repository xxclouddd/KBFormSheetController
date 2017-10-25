//
//  KBTransition.m
//  test10
//
//  Created by 肖雄 on 15/12/22.
//  Copyright © 2015年 kuaibao. All rights reserved.
//

#import "KBTransition.h"
#import "KBFormSheetController.h"

NS_ASSUME_NONNULL_BEGIN

CGFloat const KBFormSheetPresentationViewControllerDefaultAnimationDuration = 0.35;

@implementation KBTransition

+ (NSMutableDictionary *)mutableSharedTransitionClasses {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *_instanceOfTransitionClasses = nil;
    dispatch_once(&onceToken, ^{
        _instanceOfTransitionClasses = [[NSMutableDictionary alloc] init];
    });
    return _instanceOfTransitionClasses;
}

+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(KBFormSheetPresentationTransitionStyle)transitionStyle {
    [[KBTransition mutableSharedTransitionClasses] setObject:transitionClass forKey:@(transitionStyle)];
}

+ (nullable Class)classForTransitionStyle:(KBFormSheetPresentationTransitionStyle)transitionStyle {
    return [KBTransition sharedTransitionClasses][@(transitionStyle)];
}

+ (NSDictionary *)sharedTransitionClasses {
    return [[self mutableSharedTransitionClasses] copy];
}

- (void)entryFormSheetControllerTransition:(KBFormSheetController *)formSheetController completionHandler:(void (^)())completionHandler
{
    NSAssert(NO, @"must be implemented!");
}

- (void)exitFormSheetControllerTransition:(KBFormSheetController *)formSheetController completionHandler:(void (^)())completionHandler
{
    NSAssert(NO, @"must be implemented!");
}

@end


#pragma mark - KBPresentationSlideFromBottomTransition

@interface KBPresentationSlideFromBottomTransition : KBTransition
@end

@implementation KBPresentationSlideFromBottomTransition

+ (void)load
{
    [KBTransition registerTransitionClass:self forTransitionStyle:KBFormSheetPresentationTransitionStyleSlideFromBottom];
}

- (void)entryFormSheetControllerTransition:(KBFormSheetController *)formSheetController completionHandler:(void (^)())completionHandler
{
    CGRect formSheetRect = formSheetController.view.frame;
    CGRect originalFormSheetRect = formSheetRect;
    formSheetRect.origin.y = [UIScreen mainScreen].bounds.size.height;
    formSheetController.view.frame = formSheetRect;
    
    [UIView animateWithDuration:KBFormSheetPresentationViewControllerDefaultAnimationDuration
                     animations:^{
                         formSheetController.view.frame = originalFormSheetRect;
                     } completion:^(BOOL finished) {
                         completionHandler();
                     }];
}

- (void)exitFormSheetControllerTransition:(KBFormSheetController *)formSheetController completionHandler:(void (^)())completionHandler
{
    CGRect formSheetRect = formSheetController.view.frame;
    formSheetRect.origin.y = [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration:KBFormSheetPresentationViewControllerDefaultAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         formSheetController.view.frame = formSheetRect;
                     }
                     completion:^(BOOL finished) {
                         completionHandler();
                     }];
}

@end


#pragma mark - KBPresentationFadeTransition
@interface KBPresentationFadeTransition : KBTransition
@end

@implementation KBPresentationFadeTransition

+ (void)load
{
    [KBTransition registerTransitionClass:self forTransitionStyle:KBFormSheetPresentationTransitionStyleFade];
}

- (void)entryFormSheetControllerTransition:(KBFormSheetController *)formSheetController completionHandler:(void (^)())completionHandler
{
    formSheetController.view.alpha = 0;
    [UIView animateWithDuration:KBFormSheetPresentationViewControllerDefaultAnimationDuration
                     animations:^{
                         formSheetController.view.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         completionHandler();
                     }];
}

- (void)exitFormSheetControllerTransition:(KBFormSheetController *)formSheetController completionHandler:(void (^)())completionHandler
{
    [UIView animateWithDuration:KBFormSheetPresentationViewControllerDefaultAnimationDuration
                     animations:^{
                         formSheetController.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         completionHandler();
                     }];
}
@end


NS_ASSUME_NONNULL_END
