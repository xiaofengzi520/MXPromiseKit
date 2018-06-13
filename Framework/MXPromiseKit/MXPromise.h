//
//  MXPromise.h
//  MXPromiseKit
//
//  Created by Mu Xiao on 2018/6/12.
//  Copyright © 2018年 Mu Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MXPromise;
typedef void(^MXResolve) (id value);
typedef void(^MXRejected) (NSError * error);
typedef id (^MXThenHandle) (id value);
typedef MXRejected MXErrorHandle ;
typedef void(^MXPromiseBlock)(MXResolve resolve,MXRejected reject);
typedef MXPromise *(^MXPromiseThenBlock)(MXThenHandle);
typedef MXPromise *(^MXPromiseErrorBlock)(MXErrorHandle);

@interface MXPromise : NSObject

@property (nonatomic, readonly) MXPromiseThenBlock then;
@property (nonatomic, readonly) MXPromiseErrorBlock error;

+ (MXPromise *)promise:(MXPromiseBlock)resolver;

@end
