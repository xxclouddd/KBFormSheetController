//
//  UIViewController+KBFormSheetTargetViewController.h
//  KuaiDiYuan_S
//
//  Created by 肖雄 on 16/1/4.
//  Copyright © 2016年 KuaidiHelp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KBFormSheetTargetViewController)

- (nullable UIViewController *)kb_parentTargetViewController;
- (nullable UIViewController *)kb_childTargetViewControllerForStatusBarStyle;
- (nullable UIViewController *)kb_childTargetViewControllerForStatusBarHidden;

@end
