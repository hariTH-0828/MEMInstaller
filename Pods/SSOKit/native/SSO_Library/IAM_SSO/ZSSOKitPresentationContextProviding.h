//
//  ZSSOKitPresentationContextProviding.h
//  SSOKit
//
//  Created by Abinaya Ravichandran on 07/10/21.
//


@protocol ZSSOKitPresentationContextProviding <NSObject>
#if (!SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH)

- (UIWindow *)presentationAnchorForSSOKit;
#endif
@end
