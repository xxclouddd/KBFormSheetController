//
//  KBFormSheetController.h
//  test10
//
//  Created by 肖雄 on 15/12/13.
//  Copyright © 2015年 xiaoxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFormSheetBackgroundWindow.h"
#import "KBTransition.h"
#import "KBAppearance.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KBFormSheetWhenKeyboardAppears) {
    KBFormSheetWhenKeyboardAppearsDoNothing = 0,
    KBFormSheetWhenKeyboardAppearsCenterVertically,
    KBFormSheetWhenKeyboardAppearsMoveToTop,
    KBFormSheetWhenKeyboardAppearsMoveToTopInset,
    KBFormSheetWhenKeyboardAppearsMoveAboveKeyboard
};


typedef NS_ENUM(NSInteger, KBFormSheetContentVerticalAlignment) {
    KBFormSheetContentVerticalAlignmentCustom  = 0,
    KBFormSheetContentVerticalAlignmentTop     = 1,
    KBFormSheetContentVerticalAlignmentCenter  = 2,
    KBFormSheetContentVerticalAlignmentBottom  = 3,
};

typedef void(^KBFormSheetCompletionHandler)(UIViewController * presentedFSViewController);
typedef void(^KBFormSheetTransitionCompletionHandler)();


#pragma mark --- KBFormSheetWindow
@interface KBFormSheetWindow : UIWindow

@end


#pragma mark --- KBFormSheetController
@interface KBFormSheetController : UIViewController<KBAppearance>

- (instancetype)initWithViewController:(UIViewController *)presentedFormSheetViewController;

- (instancetype)initWithSize:(CGSize)formSheetSize viewController:(UIViewController *)presentedFormSheetViewController;


+ (nonnull KBFormSheetBackgroundWindow *)sharedBackgroundWindow;


/**
 The view controller that is presented by this form sheet controller.
 */
@property (nonatomic, readonly, strong, nullable) UIViewController *presentedFSViewController;

/**
 The view controller that is presenting this form sheet controller.
 */
@property (nonatomic, readonly, weak, nullable) UIViewController *presentingFSViewController;

/**
 Returns the window that form sheet controller is displayed .
 */
@property (nonatomic, readonly, strong, null_resettable) KBFormSheetWindow *formSheetWindow;

/**
 The size of presented view, default is CGSizeMake(270.0,270.0)
 */
@property (nonatomic, assign) CGSize presentedFormSheetSize UI_APPEARANCE_SELECTOR;

/**
 The corner radius of content layer, default is 6.0.
 */
@property (nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/**
 The shadow radius of content layer, default is 6.0.
 */
@property (nonatomic, assign) CGFloat shadowRadius UI_APPEARANCE_SELECTOR;

/**
 The opacity of content layer shadow, default is 0.5.
 */
@property (nonatomic, assign) CGFloat shadowOpacity UI_APPEARANCE_SELECTOR;

/**
 Whether the formsheet controller should dismiss when tap background view
 By defalut, this is YES;
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap UI_APPEARANCE_SELECTOR;

/**
 Transition style to user when presenting the receiver
 By default, this is KBFormSheetPresentationTransitionStyleFade
 */
@property (nonatomic, assign) KBFormSheetPresentationTransitionStyle transitionStyle UI_APPEARANCE_SELECTOR;

/**
 The movement style to use when the keyboard appears.
 By default, this is KBFormSheetWhenKeyboardAppearsMoveAboveKeyboard.
 */
@property (nonatomic, assign) KBFormSheetWhenKeyboardAppears movementWhenKeyboardAppears UI_APPEARANCE_SELECTOR;

/**
 How to position content vertically inside control. default is center.
 */
@property (nonatomic, assign) KBFormSheetContentVerticalAlignment contentVerticalAlignment UI_APPEARANCE_SELECTOR;

/**
 Distance that the presented form sheet view is inset from the status bar in landscape orientation.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat landscapeTopInset UI_APPEARANCE_SELECTOR;

/**
 Distance that the presented form sheet view is inset from the status bar in portrait orientation.
 By default, this is 66.0
 */
@property (nonatomic, assign) CGFloat portraitTopInset UI_APPEARANCE_SELECTOR;

/**
 Diatance of the keyboard to formsheet, when keyboard is showed.
 By default, this is 20.0
 */
@property (nonatomic, assign) CGFloat formSheetKeyboardMargin UI_APPEARANCE_SELECTOR;

/**
 The handler to call when presented form sheet is before entry transition and its view will show on window.
 */
@property (nonatomic, copy, nullable) KBFormSheetCompletionHandler willPresentCompletionHandler;

/**
 The handler to call when presented form sheet will be dismiss, this is called before out transition animation.
 */
@property (nonatomic, copy, nullable) KBFormSheetCompletionHandler willDismissCompletionHandler;

/**
 The handler to call when presented form sheet is after entry transition animation.
 */
@property (nonatomic, copy, nullable) KBFormSheetCompletionHandler didPresentCompletionHandler;

/**
 The handler to call when presented form sheet is after dismiss.
 */
@property (nonatomic, copy, nullable) KBFormSheetCompletionHandler didDismissCompletionHandler;

/**
  Show background dim. default is YES.
 */
@property (nonatomic, assign) BOOL dimsBackgroundDuringPresentation;

@end


@interface UIViewController (KBFormSheet)

@property (nonatomic, readonly, nullable) KBFormSheetController *formSheetController;

- (void)kb_presentFormSheetController:(KBFormSheetController *)formSheetController
                             animated:(BOOL)animated
                           completion:(void (^ __nullable)(void))completion;

- (void)kb_presentFormSheetWithViewController:(UIViewController *)viewController
                                     animated:(BOOL)animated
                              transitionStyle:(KBFormSheetPresentationTransitionStyle)transitionStyle
                                   completion:(void (^ __nullable)(void))completion;

- (void)kb_dismissFormSheetControllerAnimated:(BOOL)animated
                                   completion:(void (^ __nullable)(void))completion;
@end



NS_ASSUME_NONNULL_END
