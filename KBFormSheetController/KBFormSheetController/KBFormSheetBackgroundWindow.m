
//
//  KBFormSheetBackgroundWindow.m
//  test10
//
//  Created by 肖雄 on 15/12/13.
//  Copyright © 2015年 kuaibao. All rights reserved.
//

#import "KBFormSheetBackgroundWindow.h"

NS_ASSUME_NONNULL_BEGIN

UIWindowLevel const KBFormSheetBackgroundWindowLevelBelowStatusBar = 2;

CGFloat const KBFormSheetControllerDefaultBackgroundOpacity = 0.5;


@implementation KBFormSheetBackgroundWindow

+ (instancetype)appearance
{
    return [KBAppearance appearanceForClass:[self class]];
}

+ (void)load
{
    @autoreleasepool {
        KBFormSheetBackgroundWindow *appearance = [self appearance];
        [appearance setBackgroundColor:[UIColor colorWithWhite:0 alpha:KBFormSheetControllerDefaultBackgroundOpacity]];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        
        id appearance = [[self class] appearance];
        [appearance applyInvocationTo:self];
    }
    return self;
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

@end


NS_ASSUME_NONNULL_END


