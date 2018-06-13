//
//  ViewController.m
//  MXPromiseTest
//
//  Created by Mu Xiao on 2018/6/12.
//  Copyright © 2018年 Mu Xiao. All rights reserved.
//

#import "ViewController.h"
#import <MXPromiseKit/MXPromiseKit.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MXPromise *promise =  [MXPromise promise:^(MXResolve resolve, MXRejected reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            reject([NSError errorWithDomain:NSCocoaErrorDomain code:10028 userInfo:@{@"sadadsa":@"asdadasdasdasd"}]);
        });
    }].then(^id(id value){
        NSLog(@"___%@",value);
        return [MXPromise promise:^(MXResolve resolve, MXRejected reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resolve(@(5));
            });
        }];
    });
    
    promise.then(^id(id value) {
        NSLog(@"__11111_%@",value);

        return @(1000);
    }).then(^id(id value) {
        NSLog(@"__11111_%@",value);

        return [MXPromise promise:^(MXResolve resolve, MXRejected reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                reject([NSError errorWithDomain:NSCocoaErrorDomain code:1008 userInfo:@{@"msg":@"helasdasdlo"}]);
            });
        }];
    }).error(^(NSError *error)
    {
        NSLog(@"___%@", error);
    });
    promise.then(^id(id value){
        NSLog(@"___%@",value);
        return [MXPromise promise:^(MXResolve resolve, MXRejected reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resolve(@(6));
            });
        }];
    }).then(^id(id value){
        NSLog(@"___%@",value);
        return [MXPromise promise:^(MXResolve resolve, MXRejected reject) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                reject([NSError errorWithDomain:NSCocoaErrorDomain code:1007 userInfo:@{@"msg":@"hello"}]);
            });
        }];
        
    }).error(^(NSError *error){
        NSLog(@"___%@", error);
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
