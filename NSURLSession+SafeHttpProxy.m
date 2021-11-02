//
//  NSURLSession+SafeHttpProxy.m
//  MCA
//
//  Created by liuchaoyang18 on 2021/11/2.
//

#import "NSURLSession+SafeHttpProxy.h"
#import <objc/runtime.h>
static BOOL isDisableHttpProxy = YES;
@implementation NSURLSession (SafeHttpProxy)
+(void)load{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLSession class];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:") swiSel:NSSelectorFromString(@"Safe_sessionWithConfiguration:")];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:delegate:delegateQueue:") swiSel:NSSelectorFromString(@"Safe_sessionWithConfiguration:delegate:delegateQueue:")];
    });
}
+(void)disableHttpProxy{
    isDisableHttpProxy = YES;
}
+(void)enableHttpProxy{
    isDisableHttpProxy = NO;
}
+(NSURLSession *)Safe_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                    delegate:(nullable id<NSURLSessionDelegate>)delegate
                               delegateQueue:(nullable NSOperationQueue *)queue{
    if (!configuration){
        configuration = [[NSURLSessionConfiguration alloc] init];
    }
    if(isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self Safe_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+(NSURLSession *)Safe_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    if (configuration && isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self Safe_sessionWithConfiguration:configuration];
}

+(void)swizzingMethodWithClass:(Class)cls orgSel:(SEL) orgSel swiSel:(SEL) swiSel{
    Method orgMethod = class_getClassMethod(cls, orgSel);
    Method swiMethod = class_getClassMethod(cls, swiSel);
    method_exchangeImplementations(orgMethod, swiMethod);
}

@end
