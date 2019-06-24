//
//  KBFormSheetBackgroundWindow.h
//  test10
//
//  Created by 肖雄 on 15/12/13.
//  Copyright © 2015年 xiaoxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBAppearance.h"

NS_ASSUME_NONNULL_BEGIN

extern UIWindowLevel const KBFormSheetBackgroundWindowLevelBelowStatusBar;

@interface KBFormSheetBackgroundWindow : UIWindow<KBAppearance>

@property (nonatomic, copy, nullable) UIColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
