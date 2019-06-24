//
//  ViewController.m
//  KBFormSheetController
//
//  Created by 肖雄 on 17/3/1.
//  Copyright © 2017年 xiaoxiong. All rights reserved.
//

#import "ViewController.h"
#import "KBFormSheetController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIViewController *con = [[UIViewController alloc] init];
    con.view.backgroundColor = [UIColor whiteColor];
    KBFormSheetController *form = [[KBFormSheetController alloc] initWithSize:CGSizeMake(200, 200) viewController:con];
    [self kb_presentFormSheetController:form animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
