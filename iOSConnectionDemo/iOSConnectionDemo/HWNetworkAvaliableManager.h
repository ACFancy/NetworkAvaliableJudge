//
//  NetworkAvaliableManager.h
//  iOSConnectionDemo
//
//  Created by User on 2/13/18.
//  Copyright © 2018 User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWNetworkAvaliableManager : NSObject

+ (instancetype)sharedManager;
- (void)judgeNetworkAvaliableCompletion:(void(^)(BOOL avaliable))completion;

@end
