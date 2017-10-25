//
//  KBAppearance.h
//  test10
//
//  Created by 肖雄 on 15/12/29.
//  Copyright © 2015年 kuaibao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KBAppearance <NSObject>

/**
 To customize the appearance of all instances of a class, send the relevant appearance modification messages to the appearance proxy for the class. 
 */

+ (instancetype)appearance;

@end


@interface KBAppearance : NSObject

- (void)applyInvocationTo:(id)target;

- (void)applyInvocationRecursivelyTo:(id)target upToSuperClass:(Class)superClass;

+ (id)appearanceForClass:(Class)aClass;

@end
