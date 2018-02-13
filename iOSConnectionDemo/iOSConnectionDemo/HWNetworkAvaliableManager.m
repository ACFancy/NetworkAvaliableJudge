//
//  NetworkAvaliableManager.m
//  iOSConnectionDemo
//
//  Created by User on 2/13/18.
//  Copyright © 2018 User. All rights reserved.
//

#import "HWNetworkAvaliableManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#define kWWWHost @"115.239.210.27"
#define kCERTHost @"www.baidu.com"

@interface HWNetworkAvaliableManager()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (atomic, assign) BOOL isConnectting;
@property (nonatomic, strong) NSMutableArray<void(^)(BOOL avaliable)> *completionArrayM;

@end


@implementation HWNetworkAvaliableManager

#pragma mark - init Methods
static HWNetworkAvaliableManager *_instance = nil;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil) {
            _instance = [self new];
        }
    });
    return _instance;
}

- (instancetype)init {
    if(self = [super init]) {
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

#pragma mark - Public Methods
- (void)judgeNetworkAvaliableCompletion:(void(^)(BOOL avaliable))completion {
      @synchronized(self) {
          if(completion != nil) {
              [self.completionArrayM addObject:completion];
          }
          [self connectSocket];
      }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        // This is where you would (eventually) invoke SecTrustEvaluate.
        // Presumably, if you're using manual trust evaluation, you're likely doing extra stuff here.
        // For example, allowing a specific self-signed certificate that is known to the app.
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    // HTTP is a really simple protocol.
    //
    // If you don't already know all about it, this is one of the best resources I know (short and sweet):
    // http://www.jmarshall.com/easy/http/
    //
    // We're just going to tell the server to send us the metadata (essentially) about a particular resource.
    // The server will send an http response, and then immediately close the connection.
    [self writeData];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self handleCompletions:YES];
    self.isConnectting = NO;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:1.5 tag:tag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    // Since we requested HTTP/1.1, we expect the server to close the connection as soon as it has sent the response.
    if(err) {
        [self handleCompletions:NO];
    }
    self.isConnectting = NO;
}

#pragma mark - Private Methods
- (void)writeData {
    NSString *requestStr = [@"" stringByAppendingFormat:@"GET / HTTP/1.1\n\nHost:%@\n\n", kCERTHost];
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:requestData withTimeout:1.5 tag:0];
}

- (void)disconnectSocketIfConnected {
    if(self.asyncSocket && self.asyncSocket.isConnected) {
        [self.asyncSocket setDelegate:nil];
        [self.asyncSocket disconnect];
        [self.asyncSocket setDelegate:self];
    }
}

- (void)connectSocket {
    if(self.isConnectting) {
        return;
    }
    [self disconnectSocketIfConnected];
    NSError *error = nil;
    self.isConnectting = YES;
    if(![self.asyncSocket connectToHost:kWWWHost onPort:443 withTimeout:3.0 error:&error]){
        //connect fail
        self.isConnectting = NO;
        [self handleCompletions:NO];
    }
    
    NSDictionary *options = @{
                              GCDAsyncSocketUseCFStreamForTLS : @(YES),
                              GCDAsyncSocketSSLPeerName : kCERTHost
                              };
    [self.asyncSocket startTLS:options];
}

- (void)handleCompletions:(BOOL)avaliable {
    @synchronized(self) {
        NSArray<void(^)(BOOL avaliable)> *tempArray = self.completionArrayM.copy;
        for (void(^tempBlock)(BOOL) in tempArray) {
            if(tempBlock) {
                tempBlock(avaliable);
            }
            [self.completionArrayM removeObject:tempBlock];
        }
        [self disconnectSocketIfConnected];
    }
}

#pragma mark - Getter Methods
- (NSMutableArray *)completionArrayM {
    @synchronized(self) {
        if (_completionArrayM == nil) {
            _completionArrayM = @[].mutableCopy;
        }
        return _completionArrayM;
    }
}

@end
