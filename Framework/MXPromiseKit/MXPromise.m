//
//  MXPromise.m
//  MXPromiseKit
//
//  Created by Mu Xiao on 2018/6/12.
//  Copyright © 2018年 Mu Xiao. All rights reserved.
//

#import "MXPromise.h"


typedef NS_ENUM(NSUInteger, MXPromiseState) {
    MXPromiseStatePending = 0,
    MXPromiseStateFullfilled = 1,
    MXPromiseStateRejected = 2
};


@interface MXPromise()

@property (nonatomic)  MXPromiseState state;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSMutableArray<MXPromise *> *queue;
@property (nonatomic, copy) MXThenHandle thenHandle;
@property (nonatomic, copy) MXErrorHandle errorHandle;
@end

@implementation MXPromise

- (instancetype)initWithPromise:(MXPromiseBlock)resolver
{
    if (self = [super init]) {
        _state = MXPromiseStatePending;
        if (resolver) {
            [self safelyResolveThen:resolver];
        }
    }
    return self;
}

- (void)safelyResolveThen:(MXPromiseBlock)then
{
    __block BOOL called = NO;
    MXResolve resolove = ^(id value)
    {
        if (called == YES) {
            return ;
        }
        called = YES;
        [self doResolve:value];
    };
    MXRejected rejected = ^(NSError * error)
    {
        if (called == YES) {
            return ;
        }
        called = YES;
        [self doReject:error];
    };
    then(resolove, rejected);
}

+ (MXPromise *)promise:(MXPromiseBlock)block
{
    MXPromise *promise = [[self alloc] initWithPromise:block];
    return promise;
}

- (void)doReject:(NSError *)error
{
    _state = MXPromiseStateRejected;
    _value = error;
    NSAssert((error && [error isKindOfClass:[NSError class]]), @"reject必须为error");
    if (self.errorHandle) {
        self.errorHandle(error);
        self.errorHandle = nil;
    }
    for (MXPromise *item in _queue) {
        [item doReject:_value];
    }
}

- (void)doResolve:(id)value
{
    
    if ([value isKindOfClass:[NSError class]]) {
        [self doReject:value];
    }else if ([value isKindOfClass:[self class]])
    {
        MXPromise *promise = value;
        promise.then(^id(id value) {
            [self doResolve:value];
            return nil;
        }).error(^(NSError *error)
        {
            [self doReject:error];
        });
    }else if(self.thenHandle){
        id result = self.thenHandle(value);
        self.thenHandle = nil;
        [self doResolve:result];
    }else{
        _state = MXPromiseStateFullfilled;
        _value = value;
        for (MXPromise *item in _queue) {
            [item doResolve:_value];
        }
    }
}

- (NSMutableArray<MXPromise *> *)queue
{
    if (_queue == nil) {
        _queue = [NSMutableArray array];
    }
    return _queue;
}
- (MXPromiseThenBlock)then
{
    return ^MXPromise *(MXThenHandle then)
    {
        return [self then:then error:nil];
    };
}


- (MXPromise *)then:(MXThenHandle)then error:(MXErrorHandle)error
{
    MXPromise *promise = [[MXPromise alloc] initWithPromise:nil];
    if (self.state != MXPromiseStatePending) {
        if (self.state == MXPromiseStateFullfilled) {
            if (then) {
                id value = then(self.value);
                [promise doResolve:value];
            }else{
                [promise doResolve:self.value];
            }
            
        }else{
            if (error) {
                error(self.value);
            }
            [promise doReject:self.value];
        }
    }else{
        promise.thenHandle = then;
        promise.errorHandle = error;
        [self.queue addObject:promise];
    }
    return promise;
}

- (MXPromiseErrorBlock)error
{
    return ^MXPromise *(MXErrorHandle error)
    {

        return [self then:nil error:error];
    };
}

- (void)dealloc
{
    
}
@end
