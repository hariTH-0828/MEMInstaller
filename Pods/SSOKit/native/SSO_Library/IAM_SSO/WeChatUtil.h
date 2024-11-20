//
//  WeChatUtil.h
//  Pods-WeChatIAMTest
//
//  Created by Kumareshwaran on 13/03/18.
//

#import <Foundation/Foundation.h>
#include "SSORequestBlocks.h"
#if SSOKit_WECHATSDK_SUPPORTED
@interface WeChatUtil : NSObject

-(void) presentWeChatSignIn;
-(BOOL)handleWeChatOpenURL:(NSURL *)url;
-(void)handleOpenUniversalLink:(NSUserActivity *)userActivity;
@end
#endif
