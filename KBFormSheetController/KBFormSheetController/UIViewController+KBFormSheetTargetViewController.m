//
//  UIViewController+KBFormSheetTargetViewController.m
//  KuaiDiYuan_S
//
//  Created by 肖雄 on 16/1/4.
//  Copyright © 2016年 KuaidiHelp. All rights reserved.
//

#import "UIViewController+KBFormSheetTargetViewController.h"

@implementation UIViewController (KBFormSheetTargetViewController)

- (nullable UIViewController *)kb_parentTargetViewController
{
    UIViewController *parentTargetViewController = self;
    while (parentTargetViewController.presentedViewController) {
        parentTargetViewController = parentTargetViewController.presentedViewController;
    }
    return parentTargetViewController;
}

- (nullable UIViewController *)kb_childTargetViewControllerForStatusBarStyle
{
    UIViewController *childTargetViewController;
    
    if ([self respondsToSelector:@selector(childViewControllerForStatusBarStyle)]) {
        childTargetViewController = [self childViewControllerForStatusBarStyle];
        if (childTargetViewController) {
            return [childTargetViewController kb_childTargetViewControllerForStatusBarStyle];
        }
    }
    
    return self;
}

- (nullable UIViewController *)kb_childTargetViewControllerForStatusBarHidden
{
    UIViewController *childTargetViewController;
    
    if ([self respondsToSelector:@selector(childViewControllerForStatusBarHidden)]) {
        childTargetViewController = [self childViewControllerForStatusBarHidden];
        if (childTargetViewController) {
            return [childTargetViewController kb_childTargetViewControllerForStatusBarHidden];
        }
    }
    
    return self;
}

@end
