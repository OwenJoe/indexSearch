//
//  HttpRequestManager.h
//  HNB2CDemo
//
//  Created by mac_111 on 16/4/13.
//  Copyright © 2016年 mac_111. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//成功的回调
typedef void (^httpSuccess)(id responseObject);
//失败的回调
typedef void (^httpFailure)(NSError *error);

@interface HttpRequestManager : NSObject
+ (instancetype)shareInstance;

// post 请求
+ (void)HttpPostCallBack:(NSString*)Url  Parameters:(NSDictionary*)dict success:(httpSuccess)success failure:(httpFailure)failure;

// get  请求
+ (void)HttpGetCallBack:(NSString*)Url  Parameters:(NSDictionary*)dict success:(httpSuccess)success failure:(httpFailure)failure;

//get  请求添加了forHTTPHeaderField
+ (void)HttpGetCallack:(NSString *)Url Parameters:(NSDictionary *)dict headers:(NSDictionary *)dict success:(httpSuccess)success failure:(httpFailure)failure;

@end
