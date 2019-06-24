//
//  KBFormSheetBackgroundWindowViewController.h
//  test10
//
//  Created by 肖雄 on 16/1/4.
//  Copyright © 2016年 xiaoxiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBFormSheetBackgroundWindowViewController : UIViewController

@property (nonatomic, assign) UIStatusBarStyle preferredStatusBarStyleForBackgroundWindow;
@property (nonatomic, assign) BOOL prefersStatusBarHiddenForBackgroundWindow;

+ (instancetype)viewControllerWithPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle
                                   prefersStatusBarHidden:(BOOL)prefersStatusBarHidden;

@end
