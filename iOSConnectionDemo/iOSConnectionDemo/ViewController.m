//
//  ViewController.m
//  iOSConnectionDemo
//
//  Created by User on 2/12/18.
//  Copyright © 2018 User. All rights reserved.
//

#import "ViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "HWNetworkAvaliableManager.h"

//#define  WWW_HOST @"115.239.210.27"
//#define CERT_HOST @"www.baidu.com"

@interface ViewController ()<GCDAsyncSocketDelegate>
//@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
//@property (atomic, assign) BOOL isConnectting;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = (CGRect){50, 100, 100 , 100};
    [btn addTarget:self action:@selector(resend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
//    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self resend];
}

- (void)resend {
    [[HWNetworkAvaliableManager sharedManager] judgeNetworkAvaliableCompletion:^(BOOL avaliable) {
        UIAlertView *alertV =  [[UIAlertView alloc] initWithTitle:@"" message:(avaliable ? @"有网" : @"无网络") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertV show];
    }];
//    if(self.isConnectting) {
//        return;
//    }
//    [self disconnectIfConnected];
//    NSError *error = nil;
//    self.isConnectting = YES;
//    if(![self.asyncSocket connectToHost:WWW_HOST onPort:443 withTimeout:3.0 error:&error]){
//        NSLog(@"dog-XXX:%@", error.localizedDescription);
//        self.isConnectting = NO;
//        UIAlertView *alertV =  [[UIAlertView alloc] initWithTitle:@"" message:@"Connect Error" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alertV show];
//    }else {
//        NSLog(@"dog-FFFF");
//    }
//
//    NSDictionary *options = @{
//                              GCDAsyncSocketUseCFStreamForTLS : @(YES),
//                              GCDAsyncSocketSSLPeerName : CERT_HOST
//                              };
//
//    [self.asyncSocket startTLS:options];
}
//
//- (void)disconnectIfConnected {
//    if(self.asyncSocket && self.asyncSocket.isConnected) {
//        [self.asyncSocket setDelegate:nil];
//        [self.asyncSocket disconnect];
//        [self.asyncSocket setDelegate:self];
//    }
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
//completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
//{
//    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(bgQueue, ^{
//
//        // This is where you would (eventually) invoke SecTrustEvaluate.
//        // Presumably, if you're using manual trust evaluation, you're likely doing extra stuff here.
//        // For example, allowing a specific self-signed certificate that is known to the app.
//
//        SecTrustResultType result = kSecTrustResultDeny;
//        OSStatus status = SecTrustEvaluate(trust, &result);
//
//        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
//            completionHandler(YES);
//        }
//        else {
//            completionHandler(NO);
//        }
//    });
//}
//
//- (void)writeData {
//    NSString *requestStr = [@"" stringByAppendingFormat:@"GET / HTTP/1.1\n\nHost:%@\n\n", CERT_HOST];
//    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
//
//    [self.asyncSocket writeData:requestData withTimeout:1.5 tag:0];
//    NSLog(@"Full httpRequest:\n%@", requestStr);
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
//{
//    NSLog(@"socket:didConnectToHost:%@ port:%hu", host, port);
//
//    // HTTP is a really simple protocol.
//    //
//    // If you don't already know all about it, this is one of the best resources I know (short and sweet):
//    // http://www.jmarshall.com/easy/http/
//    //
//    // We're just going to tell the server to send us the metadata (essentially) about a particular resource.
//    // The server will send an http response, and then immediately close the connection.
//    [self writeData];
//
//}
//
//
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//    NSLog(@"socket:didReadData:withTag:");
//
//    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//    NSLog(@"Full httpResponse:\n%@", httpResponse);
//    if([httpResponse containsString:@"HTTP/1.1 200 OK"]) {
//        UIAlertView *alertV =  [[UIAlertView alloc] initWithTitle:@"" message:@"OK" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alertV show];
//    }else {
//        UIAlertView *alertV =  [[UIAlertView alloc] initWithTitle:@"" message:@"Error" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alertV show];
//    }
//    self.isConnectting = NO;
//
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//    //发送完数据手动读取，-1不设置超时
//    [sock readDataWithTimeout:1.5 tag:tag];
//}
//
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//{
//    // Since we requested HTTP/1.0, we expect the server to close the connection as soon as it has sent the response.
//    if(err) {
//        UIAlertView *alertV =  [[UIAlertView alloc] initWithTitle:@"" message:@"CloseError" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alertV show];
//       NSLog(@"socketDidDisconnect:%p withError:%@", sock, err);
//    }else {
//        UIAlertView *alertV =  [[UIAlertView alloc] initWithTitle:@"" message:@"Close" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [alertV show];
//    }
//    self.isConnectting = NO;
//    NSLog(@"%zd", self.asyncSocket.isConnected);
//}

@end
