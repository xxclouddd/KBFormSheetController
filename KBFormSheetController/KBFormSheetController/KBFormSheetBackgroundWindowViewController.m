//
//  KBFormSheetBackgroundWindowViewController.m
//  test10
//
//  Created by 肖雄 on 16/1/4.
//  Copyright © 2016年 xiaoxiong. All rights reserved.
//

#import "KBFormSheetBackgroundWindowViewController.h"

@interface KBFormSheetBackgroundWindowViewController ()

@end

@implementation KBFormSheetBackgroundWindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (instancetype)viewControllerWithPreferredStatusBarStyle:(UIStatusBarStyle)preferredStatusBarStyle prefersStatusBarHidden:(BOOL)prefersStatusBarHidden
{
    KBFormSheetBackgroundWindowViewController *viewController = [[self alloc] init];
    viewController.preferredStatusBarStyleForBackgroundWindow = preferredStatusBarStyle;
    viewController.prefersStatusBarHiddenForBackgroundWindow = prefersStatusBarHidden;
    return viewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.preferredStatusBarStyleForBackgroundWindow;
}

- (BOOL)prefersStatusBarHidden {
    return self.prefersStatusBarHiddenForBackgroundWindow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
