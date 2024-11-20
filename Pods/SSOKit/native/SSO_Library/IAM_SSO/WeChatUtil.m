//
//  WeChatUtil.m
//  Pods-WeChatIAMTest
//
//  Created by Kumareshwaran on 13/03/18.
//
#if SSOKit_WECHATSDK_SUPPORTED
#import "WeChatUtil.h"
#import <WechatOpenSDK/WXApi.h>
#include "ZIAMUtil.h"
#include "ZIAMUtilConstants.h"
#include "SSONetworkManager.h"
#include "SSOSFSafariViewController.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"

@interface WeChatUtil () <WXApiDelegate>

@end

@implementation WeChatUtil

-(void) presentWeChatSignIn{
   
    BOOL registrationStatus =  [WXApi registerApp:[ZIAMUtil sharedUtil]->weChatAppID universalLink:[ZIAMUtil sharedUtil]->weChatUniversalLink];
    //BOOL registrationStatus =  [WXApi registerApp:[ZIAMUtil sharedUtil]->weChatAppID];
    SendAuthReq *request = [[SendAuthReq alloc] init];
    //request.scope = @"snsapi_login";
    request.scope = @"snsapi_userinfo";
    
    request.state = [[NSUUID UUID] UUIDString];
    [WXApi sendAuthReq:request viewController:[[ZIAMUtil sharedUtil]topViewController] delegate:self completion:^(BOOL success) {
        //Completion
        if(success){
            DLog(@"SendAuth Request Completeion Success");
        }

    }];
    //[WXApi sendAuthReq:request viewController:[[ZIAMUtil sharedUtil]topViewController] delegate:self];
}

-(BOOL)handleWeChatOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

-(void)handleOpenUniversalLink:(NSUserActivity *)userActivity{
    [WXApi handleOpenUniversalLink:userActivity delegate:self];
}



#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req {
    DLog(@"WeChat API delegate [onRequest]: <%@>", req);
}


- (void)onResp:(BaseResp *)resp {
    DLog(@"WeChat API delegate [onResponse]: <%@>", resp);
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResponse = (SendAuthResp *)resp;
        DLog(@"Auth Response: %@\n Code: %@", authResponse, authResponse.code);
        NSString *url =@"https://api.weixin.qq.com/sns/oauth2/access_token";
        [[ZIAMUtil sharedUtil] proceedSignInUsingGrantToken:authResponse.code forProvider:@"wechat"];
        
//        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
//        [paramsAndHeaders setValue:[ZIAMUtil sharedUtil]->weChatAppID forKey:@"appid"];
//        [paramsAndHeaders setValue:[ZIAMUtil sharedUtil]->weChatAppSecret forKey:@"secret"];
//        [paramsAndHeaders setValue:authResponse.code forKey:@"code"];
//        [paramsAndHeaders setValue:@"authorization_code" forKey:@"grant_type"];
//        [[SSONetworkManager sharedManager] sendPOSTRequestForURL:url parameters:paramsAndHeaders successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
//            //            {   "access_token":"ACCESS_TOKEN",
//            //                "expires_in":7200,
//            //                "refresh_token":"REFRESH_TOKEN",
//            //                "openid":"OPENID",
//            //                "scope":"SCOPE",
//            //                "unionid": "o6_bmasdasdsad6_2sgVt7hMZOPfL" }
//            NSString *access_token = [jsonDict objectForKey:@"access_token"];
//            DLog(@"WeChat OAuth Post Success Access Token:%@",access_token);
//        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
//            DLog(@"WeChat OAuth Post Failed");
//        }];
        
    }
}
@end
#endif
