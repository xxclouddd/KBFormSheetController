//
//  KBTransition.h
//  test10
//
//  Created by 肖雄 on 15/12/22.
//  Copyright © 2015年 xiaoxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
@class KBFormSheetController;

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const KBFormSheetPresentationViewControllerDefaultAnimationDuration;

typedef NS_ENUM(NSInteger, KBFormSheetPresentationTransitionStyle) {
    KBFormSheetPresentationTransitionStyleSlideFromBottom,
    KBFormSheetPresentationTransitionStyleFade,
    KBFormSheetPresentationTransitionStyleCustom
};

@protocol KBFormSheetPresentationViewControllerTransitionProtocol <NSObject>
/**
 Subclasses must implement to add custom transition animation.
 When animation is finished you must call super method or completionHandler to
 keep view life cycle.
 */
- (void)entryFormSheetControllerTransition:(KBFormSheetController *)formSheetController
                         completionHandler:(void(^)())completionHandler;

- (void)exitFormSheetControllerTransition:(KBFormSheetController *)formSheetController
                        completionHandler:(void(^)())completionHandler;

@end


@interface KBTransition : NSObject<KBFormSheetPresentationViewControllerTransitionProtocol>

+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(KBFormSheetPresentationTransitionStyle)transitionStyle;

+ (nullable Class)classForTransitionStyle:(KBFormSheetPresentationTransitionStyle)transitionStyle;

+ (NSDictionary *)sharedTransitionClasses;


@end

NS_ASSUME_NONNULL_END
