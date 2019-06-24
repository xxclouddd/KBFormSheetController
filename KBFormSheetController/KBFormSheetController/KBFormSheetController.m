
//
//  KBFormSheetController.m
//  test10
//
//  Created by 肖雄 on 15/12/13.
//  Copyright © 2015年 xiaoxiong. All rights reserved.
//

#import "KBFormSheetController.h"
#import <objc/runtime.h>
#import "KBFormSheetBackgroundWindowViewController.h"
#import "UIViewController+KBFormSheetTargetViewController.h"

NS_ASSUME_NONNULL_BEGIN

CGFloat const KBFormSheetControllerDefaultAnimationDuration = 0.3;
CGFloat const KBFormSheetKeyboardMargin = 20;

CGFloat const KBFormSheetPresentedControllerDefaultCornerRadius = 6.0;
CGFloat const KBFormSheetPresentedControllerDefaultShadowRadius = 4.0;
CGFloat const KBFormSheetPresentedControllerDefaultShadowOpacity = 0.3;

CGFloat const KBFormSheetControllerDefaultWidth = 270.0;
CGFloat const KBFormSheetControllerDefaultHeight = 270.0;
CGFloat const KBFormSheetControllerDefaultPortraitTopInset = 66.0;
CGFloat const KBFormSheetControllerDefaultLandscapeTopInset = 6.0;


static  KBFormSheetBackgroundWindow * _Nullable _instanceOfFormSheetBackgroundWindow = nil;
static NSMutableArray *_instanceOfSharedQueue = nil;

static CGFloat kb_formSheetController_statusBarHeight(){
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    } else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationIsLandscape(orientation)) {
            return [UIApplication sharedApplication].statusBarFrame.size.width;
        } else {
            return [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }
}

static CGFloat kb_formSheetController_topOffset(){
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        return kb_formSheetController_statusBarHeight();
    } else {
        return 0;
    }
}


#pragma mark - UIViewController (OBJC_ASSOCIATION)
@implementation UIViewController (OBJC_ASSOCIATION)
static const char* kb_formSheetController = "kb_formSheetController";

- (nullable KBFormSheetController *)formSheetController
{
    return objc_getAssociatedObject(self, kb_formSheetController);
}

- (void)setFormSheetController:(nullable KBFormSheetController *)formSheetController
{
    objc_setAssociatedObject(self, kb_formSheetController, formSheetController, OBJC_ASSOCIATION_ASSIGN);
}

@end


#pragma mark - KBFormSheetWindow
@implementation KBFormSheetWindow

@end


#pragma mark - KBFormSheetController

@interface KBFormSheetController ()<UIGestureRecognizerDelegate>

@property (nonatomic, readwrite, strong, null_resettable) KBFormSheetWindow *formSheetWindow;

@property (nonatomic, readwrite, strong, nullable) UIViewController *presentedFSViewController;
@property (nonatomic, readwrite, weak, nullable) UIViewController *presentingFSViewController;

@property (nonatomic, strong) KBTransition *transition;

@property (nonatomic, readonly) CGFloat topInset;
@property (nonatomic, assign, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic, strong, nullable) NSValue *screenFrameWhenKeyboardVisible;

@property (nonatomic, strong, nullable) UITapGestureRecognizer *backgroundTapGestureRecognizer;

@end

@implementation KBFormSheetController

+ (instancetype)appearance
{
    return [KBAppearance appearanceForClass:[self class]];
}

+ (void)load
{
    @autoreleasepool {
        KBFormSheetController *appearance = [self appearance];
        [appearance setPresentedFormSheetSize:CGSizeMake(KBFormSheetControllerDefaultWidth, KBFormSheetControllerDefaultHeight)];
        [appearance setCornerRadius:KBFormSheetPresentedControllerDefaultCornerRadius];
        [appearance setShadowOpacity:KBFormSheetPresentedControllerDefaultShadowOpacity];
        [appearance setShadowRadius:KBFormSheetPresentedControllerDefaultShadowRadius];
        [appearance setLandscapeTopInset:KBFormSheetControllerDefaultLandscapeTopInset];
        [appearance setPortraitTopInset:KBFormSheetControllerDefaultPortraitTopInset];
        [appearance setMovementWhenKeyboardAppears:KBFormSheetWhenKeyboardAppearsCenterVertically];
        [appearance setShouldDismissOnBackgroundViewTap:YES];
        [appearance setContentVerticalAlignment:KBFormSheetContentVerticalAlignmentCenter];
        [appearance setTransitionStyle:KBFormSheetPresentationTransitionStyleFade];
        [appearance setFormSheetKeyboardMargin:KBFormSheetKeyboardMargin];
        [appearance setDimsBackgroundDuringPresentation:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addKeyboardNotifications];
    [self addBackgroundGesture];
    
    if (self.presentedFSViewController) {
        [self addChildViewController:self.presentedFSViewController];
        [self.view addSubview:self.presentedFSViewController.view];
        [self.presentedFSViewController didMoveToParentViewController:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc
{
    [self removeKeyboardNotifications];
}

#pragma mark - public methods
- (instancetype)initWithViewController:(UIViewController *)presentedFormSheetViewController
{
    self = [super init];
    if (self) {
        presentedFormSheetViewController.formSheetController = self;
        self.presentedFSViewController = presentedFormSheetViewController;
        
        id appearance = [[self class] appearance];
        [appearance applyInvocationRecursivelyTo:self upToSuperClass:[KBFormSheetController class]];
        
        [self setupFormSheetViewController];
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)formSheetSize viewController:(UIViewController *)presentedFormSheetViewController
{
    if (self = [self initWithViewController:presentedFormSheetViewController]) {
        if (!CGSizeEqualToSize(formSheetSize, CGSizeZero)) {
            _presentedFormSheetSize = formSheetSize;
            [self setupFormSheetViewController];
        }
    }
    return self;
}

#pragma mark - helper

#pragma mark - rotation

#pragma mark - show/dismiss backgroundWindow
- (void)showBackgroundWindowAnimated:(BOOL)animated
{
    if ([KBFormSheetController sharedBackgroundWindow].isHidden)
    {
        UIViewController *mostTopViewController = [[[[KBFormSheetController sharedQueue] firstObject] presentingFSViewController] kb_parentTargetViewController];
        UIViewController* statusBarStyleResponsibleViewController = [mostTopViewController kb_childTargetViewControllerForStatusBarStyle];
        UIViewController* statusBarHiddenResponsibleViewController = [mostTopViewController kb_childTargetViewControllerForStatusBarHidden];
        
        _instanceOfFormSheetBackgroundWindow.rootViewController = [KBFormSheetBackgroundWindowViewController viewControllerWithPreferredStatusBarStyle:statusBarStyleResponsibleViewController.preferredStatusBarStyle prefersStatusBarHidden:statusBarHiddenResponsibleViewController.prefersStatusBarHidden];
        [_instanceOfFormSheetBackgroundWindow makeKeyAndVisible];
        
        _instanceOfFormSheetBackgroundWindow.alpha = 0;
        if (animated) {
            [UIView animateWithDuration:KBFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 _instanceOfFormSheetBackgroundWindow.alpha = 1;
                             }];
        } else {
            _instanceOfFormSheetBackgroundWindow.alpha = 1;
        }
    }
}

- (void)dismissBackgroundWindowAnimation:(BOOL)animated completion:(void (^)())completion
{
    if (_instanceOfFormSheetBackgroundWindow == nil) {
        completion ? completion() : nil;
        return;
    }
    
    if (!animated) {
        [_instanceOfFormSheetBackgroundWindow removeFromSuperview];
        _instanceOfFormSheetBackgroundWindow = nil;
        
        completion ? completion() : nil;
        return;
    }
    
    [UIView animateWithDuration:KBFormSheetControllerDefaultAnimationDuration
                     animations:^{
                         _instanceOfFormSheetBackgroundWindow.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [_instanceOfFormSheetBackgroundWindow removeFromSuperview];
                         _instanceOfFormSheetBackgroundWindow = nil;
                         
                         completion ? completion() : nil;
                     }];
}

#pragma mark - public methods
- (void)presentAnimated:(BOOL)animated completionHandler:(nullable KBFormSheetCompletionHandler)completionHandler
{
    NSAssert(self.presentedFSViewController, @"KBFormSheetController must have at least one view controller.");
    
    // add to golbal queue
    if (![[KBFormSheetController sharedQueue] containsObject:self]) {
        [[KBFormSheetController sharedQueue] addObject:self];
    }
    
    if (self.dimsBackgroundDuringPresentation) {
        // show background window
        [self showBackgroundWindowAnimated:YES];
    }
    
    
    // make formsheetWindow visible
    self.formSheetWindow.userInteractionEnabled = NO;
    [self.formSheetWindow makeKeyAndVisible];


    // setup frame
    [self setupPresentedFSViewControllerFrame];

    if (self.willPresentCompletionHandler) {
        self.willPresentCompletionHandler(self.presentedFSViewController);
    }
    
    KBFormSheetTransitionCompletionHandler transitionCompletionHandler = ^(){
        self.formSheetWindow.hidden = NO;
        self.formSheetWindow.userInteractionEnabled = YES;
        
        if (self.didPresentCompletionHandler) {
            self.didPresentCompletionHandler(self.presentedFSViewController);
        }
        
        if (completionHandler) {
            completionHandler(self.presentedFSViewController);
        }
    };
    
    if (animated) {
        [self transitionEntryWithCompletionBlock:transitionCompletionHandler];
    } else {
        transitionCompletionHandler();
    }
}

- (void)dismissAnimated:(BOOL)animated completionHandler:(nullable KBFormSheetCompletionHandler)completionHandler
{
    self.formSheetWindow.userInteractionEnabled = NO;
    
    // remove self from global queue
    [[KBFormSheetController sharedQueue] removeObject:self];

    // remove keyboard notification
    [self removeKeyboardNotifications];

    
    if (self.willDismissCompletionHandler) {
        self.willDismissCompletionHandler(self.presentedFSViewController);
    }
    
    dispatch_queue_t dissmissQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_group_t dissmissGroup = dispatch_group_create();
    
    if ([KBFormSheetController sharedQueue].count == 0) {
        dispatch_group_enter(dissmissGroup);
        [self dismissBackgroundWindowAnimation:animated completion:^{
            dispatch_group_leave(dissmissGroup);
        }];
    }

    
    KBFormSheetTransitionCompletionHandler transitionCompletionHandler = ^(){
        [self cleanupForSheetWindow];
        dispatch_group_leave(dissmissGroup);
    };

    
    dispatch_group_enter(dissmissGroup);
    if (animated) {
        [self transitionOutWithCompletionBlock:transitionCompletionHandler];
    } else {
        transitionCompletionHandler();
    }

    
    dispatch_group_notify(dissmissGroup, dissmissQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.didDismissCompletionHandler) {
                self.didDismissCompletionHandler(self.presentedFSViewController);
            }
            
            if (completionHandler) {
                completionHandler(self.presentedFSViewController);
            }
            [self cleanupPresentedViewController];
        });
    });
    

    // protect
    UIWindow *applicationKeyWindow = [[[UIApplication sharedApplication] delegate] window];
    applicationKeyWindow.userInteractionEnabled = YES;
    [applicationKeyWindow makeKeyWindow];
    applicationKeyWindow.hidden = NO;
}

#pragma mark - clean
- (void)cleanupForSheetWindow
{
    self.presentedFSViewController.formSheetController = nil;
    self.presentingFSViewController.formSheetController = nil;
    
    // because self is formSheetWindow's root controller. so must clean formSheetWindow
    [self.formSheetWindow removeGestureRecognizer:self.backgroundTapGestureRecognizer];
    self.backgroundTapGestureRecognizer = nil;

    self.formSheetWindow.hidden = YES;
    self.formSheetWindow.rootViewController = nil;
    [self.formSheetWindow removeFromSuperview];
    self.formSheetWindow = nil;
    
    [self removeKeyboardNotifications];
}

- (void)setPresentingFSViewController:(nullable UIViewController *)presentingFSViewController
{
    _presentingFSViewController = presentingFSViewController;
}

- (void)cleanupPresentedViewController
{
    [self.presentedFSViewController willMoveToParentViewController:nil];
    [self.presentedFSViewController.view removeFromSuperview];
    [self.presentedFSViewController removeFromParentViewController];
    self.presentedFSViewController = nil;
}

#pragma mark - Transitions
- (void)transitionEntryWithCompletionBlock:(KBFormSheetTransitionCompletionHandler)completionBlock
{
    Class transitionClass = [KBTransition sharedTransitionClasses][@(self.transitionStyle)];
    
    if (transitionClass) {
        id <KBFormSheetPresentationViewControllerTransitionProtocol> transition = [[transitionClass alloc] init];
        [transition entryFormSheetControllerTransition:self
                                     completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)transitionOutWithCompletionBlock:(KBFormSheetTransitionCompletionHandler)completionBlock
{
    Class transitionClass = [KBTransition sharedTransitionClasses][@(self.transitionStyle)];
    
    if (transitionClass) {
        id <KBFormSheetPresentationViewControllerTransitionProtocol> transition = [[transitionClass alloc] init];
        [transition exitFormSheetControllerTransition:self
                                    completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)resetTransition
{
    [self.presentedFSViewController.view.layer removeAllAnimations];
}

#pragma mark - setup
- (void)setupFormSheetViewController
{
    self.presentedFSViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    self.presentedFSViewController.view.frame = CGRectMake(0, 0,self.presentedFormSheetSize.width, self.presentedFormSheetSize.height);
    self.presentedFSViewController.view.layer.cornerRadius = self.cornerRadius;
    self.presentedFSViewController.view.layer.masksToBounds = YES;
    self.presentedFSViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.presentedFSViewController.view.center.y);

    self.view.layer.shadowOffset = CGSizeZero;
    self.view.layer.shadowRadius = self.shadowRadius;
    self.view.layer.shadowOpacity = self.shadowOpacity;
    self.view.frame = self.presentedFSViewController.view.frame;
}


/* setup first conotrller frame when consider keyboard or any other margin.
 */
- (void)setupPresentedFSViewControllerFrame
{
    if (self.keyboardVisible) {
        CGRect formSheetRect = self.presentedFSViewController.view.frame;
        CGRect screenRect = [self.screenFrameWhenKeyboardVisible CGRectValue];
        
        switch (self.movementWhenKeyboardAppears) {
            case KBFormSheetWhenKeyboardAppearsCenterVertically:
                formSheetRect.origin.y = (kb_formSheetController_statusBarHeight() + screenRect.size.height - formSheetRect.size.height)/2 - screenRect.origin.y;
                break;
            case KBFormSheetWhenKeyboardAppearsMoveToTop:
                formSheetRect.origin.y = kb_formSheetController_topOffset();
                break;
            case KBFormSheetWhenKeyboardAppearsMoveToTopInset:
                formSheetRect.origin.y = self.topInset;
                break;
            case KBFormSheetWhenKeyboardAppearsMoveAboveKeyboard:
                formSheetRect.origin.y = formSheetRect.origin.y + (screenRect.size.height - CGRectGetMaxY(formSheetRect)) - self.formSheetKeyboardMargin;
            case KBFormSheetWhenKeyboardAppearsDoNothing:
                
            default:
                break;
        }
        self.presentedFSViewController.view.frame = formSheetRect;
        
    } else {
        CGRect frame = self.presentedFSViewController.view.frame;
        switch (self.contentVerticalAlignment) {
            case KBFormSheetContentVerticalAlignmentCustom:
                frame.origin.y = self.topInset;
                self.presentedFSViewController.view.frame = frame;
                break;
            case KBFormSheetContentVerticalAlignmentTop:
                frame.origin.y = kb_formSheetController_topOffset();
                self.presentedFSViewController.view.frame = frame;
                break;
            case KBFormSheetContentVerticalAlignmentCenter:
                self.presentedFSViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
                break;
            case KBFormSheetContentVerticalAlignmentBottom:
                frame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(frame);
                self.presentedFSViewController.view.frame = frame;
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - UIKeyboard notification
- (void)addKeyboardNotifications
{
    [self removeKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)willShowKeyboardNotification:(NSNotification *)notification
{
    CGRect screenRect = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && [[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        screenRect.size.height = [UIScreen mainScreen].bounds.size.width - screenRect.size.width;
        screenRect.size.width = [UIScreen mainScreen].bounds.size.height;
    } else {
        screenRect.size.height = [UIScreen mainScreen].bounds.size.height - screenRect.size.height;
        screenRect.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        screenRect.origin.y = 0;
    } else {
        screenRect.origin.y = kb_formSheetController_statusBarHeight();
    }
    
    
    self.screenFrameWhenKeyboardVisible = [NSValue valueWithCGRect:screenRect];
    self.keyboardVisible = YES;


    [UIView animateWithDuration:KBFormSheetControllerDefaultAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setupPresentedFSViewControllerFrame];
                     }
                     completion:nil];
}

- (void)willHideKeyboardNotification:(NSNotification *)notification
{
    self.keyboardVisible = NO;
    self.screenFrameWhenKeyboardVisible = nil;
    
    [UIView animateWithDuration:KBFormSheetControllerDefaultAnimationDuration
                          delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setupPresentedFSViewControllerFrame];
                     }
                     completion:nil];
}

#pragma mark - UIGestureRecognizers
- (void)addBackgroundGesture
{
    self.backgroundTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(handleTapGestureRecognizer:)];
    _backgroundTapGestureRecognizer.delegate = self;
    [self.formSheetWindow addGestureRecognizer:_backgroundTapGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.view) {
        return YES;
    }
    return NO;
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded && [KBFormSheetController sharedQueue].count > 0){
        if (self.shouldDismissOnBackgroundViewTap) {
            [self dismissAnimated:YES completionHandler:nil];
        }
    }    
}

#pragma mark - Class methods
+ (KBFormSheetBackgroundWindow *)sharedBackgroundWindow
{
    if (!_instanceOfFormSheetBackgroundWindow) {
        _instanceOfFormSheetBackgroundWindow = [[KBFormSheetBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _instanceOfFormSheetBackgroundWindow.windowLevel = KBFormSheetBackgroundWindowLevelBelowStatusBar;
    }
    return _instanceOfFormSheetBackgroundWindow;    
}

+ (NSMutableArray *)sharedQueue
{
    if (!_instanceOfSharedQueue) {
        _instanceOfSharedQueue = [NSMutableArray array];
    }
    return _instanceOfSharedQueue;
}

#pragma mark - overload
- (nullable UIViewController *)childViewControllerForStatusBarStyle
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return [navigationController.topViewController kb_childTargetViewControllerForStatusBarStyle];
    }
    
    return [self.presentedFSViewController kb_childTargetViewControllerForStatusBarStyle];
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return [navigationController.topViewController kb_childTargetViewControllerForStatusBarStyle];
    }
    return [self.presentedFSViewController kb_childTargetViewControllerForStatusBarStyle];
}

#pragma mark - getter
- (CGFloat)topInset
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return self.portraitTopInset;
    } else {
        return self.landscapeTopInset;
    }
}

- (KBFormSheetWindow *)formSheetWindow
{
    if (!_formSheetWindow) {
        KBFormSheetWindow *window = [[KBFormSheetWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = [KBFormSheetController sharedBackgroundWindow].windowLevel + 1;
        window.rootViewController = self;
        _formSheetWindow = window;
    }
    
    return _formSheetWindow;
}

- (KBTransition *)transition
{
    if (_transition == nil) {
        _transition = [[KBTransition alloc] init];
    }
    return _transition;
}

#pragma mark - setter
- (void)setPortraitTopInset:(CGFloat)portraitTopInset
{
    if (_portraitTopInset != portraitTopInset) {
        _portraitTopInset = portraitTopInset + kb_formSheetController_topOffset();
    }
}

- (void)setLandscapeTopInset:(CGFloat)landscapeTopInset
{
    if (_landscapeTopInset != landscapeTopInset) {
        _landscapeTopInset = landscapeTopInset + kb_formSheetController_topOffset();
    }
}

- (void)setPresentedFormSheetSize:(CGSize)presentedFormSheetSize
{
    if (!CGSizeEqualToSize(_presentedFormSheetSize, presentedFormSheetSize)) {
        _presentedFormSheetSize = CGSizeMake(nearbyintf(presentedFormSheetSize.width), nearbyintf(presentedFormSheetSize.height));
        
        CGPoint presentedFormCenter = self.presentedFSViewController.view.center;
        self.presentedFSViewController.view.frame = CGRectMake(presentedFormCenter.x - _presentedFormSheetSize.width / 2,
                                                               presentedFormCenter.y - _presentedFormSheetSize.height / 2,
                                                               _presentedFormSheetSize.width,
                                                               _presentedFormSheetSize.height);
        self.presentedFSViewController.view.center = presentedFormCenter;
        
        // This will make sure that origin be in good position
        [self setupPresentedFSViewControllerFrame];
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    self.view.layer.shadowRadius = shadowRadius;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    self.view.layer.shadowOpacity = shadowOpacity;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.presentedFSViewController.view.layer.cornerRadius = _cornerRadius;
}

@end


#pragma mark - UIViewController (KBFormSheet)
@implementation UIViewController (KBFormSheet)
@dynamic formSheetController;

- (void)kb_presentFormSheetController:(KBFormSheetController *)formSheetController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;
{
    self.formSheetController = formSheetController;
    formSheetController.presentingFSViewController = self;
    
    [formSheetController presentAnimated:animated completionHandler:^(UIViewController * _Nonnull presentedFSViewController) {
        completion ? completion() : nil;
    }];
}

- (void)kb_presentFormSheetWithViewController:(UIViewController *)viewController animated:(BOOL)animated transitionStyle:(KBFormSheetPresentationTransitionStyle)transitionStyle completion:(void (^ __nullable)(void))completion
{
    KBFormSheetController *formSheetController = [[KBFormSheetController alloc] initWithViewController:viewController];
    formSheetController.transitionStyle = transitionStyle;
    formSheetController.presentingFSViewController = self;

    [self kb_presentFormSheetController:formSheetController animated:animated completion:completion];
}

- (void)kb_dismissFormSheetControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion
{
    KBFormSheetController *formSheetController = nil;
    
    if (self.formSheetController) {
        formSheetController = self.formSheetController;
    } else {
        formSheetController = [[KBFormSheetController sharedQueue] lastObject];
    }
    
    [formSheetController dismissAnimated:animated completionHandler:^(UIViewController * _Nonnull presentedFSViewController) {
        completion ? completion() : nil;
    }];
}

@end





NS_ASSUME_NONNULL_END
