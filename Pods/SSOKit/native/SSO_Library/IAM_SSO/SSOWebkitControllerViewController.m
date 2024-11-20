//
//  SSOWebkitControllerViewController.m
//  SSOKit-iOS
//
//  Created by Abinaya Ravichandran on 16/04/23.
//
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

#import "SSOWebkitControllerViewController.h"
#import <WebKit/WebKit.h>
#import "UIView+ZIAMView.h"
#import "SSOConstants.h"
#import "ZIAMUtilConstants.h"
#import "ZIAMUtil.h"

@interface SSOWebkitControllerViewController ()<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation SSOWebkitControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    
    UIImage *closeImage = [UIImage imageNamed:@"ssokit_close" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleClose)];
    navigationItem.leftBarButtonItem = closeBarButton;
    
    navigationBar.items = @[navigationItem];
    [self.view addSubview:navigationBar];
    [navigationBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    if (@available(iOS 11.0, *)) {
        [navigationBar pinTopToSuperViewSafeArea:0];
    } else {
        // Fallback on earlier versions
        [navigationBar pinTopToSuperView:0];

    }
    [navigationBar pinLeadingToSuperView:0];
    [navigationBar pinTrailingToSuperView:0];
    
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.webView];
    [self.webView setNavigationDelegate:self];
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.webView pinTopTo:navigationBar constant:0];
    [self.webView pinBottomToSuperView:0];
    [self.webView pinLeadingToSuperView:0];
    [self.webView pinTrailingToSuperView:0];


    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.urlForWebView];
    
    for (NSString* key in self.headers) {
        NSString* value = self.headers[key];
        if ([key isEqualToString:SSOWebSessionUserAgent]) {
            self.webView.customUserAgent = value;
            continue;
        }
        [request setValue:value forHTTPHeaderField:key];
    }
    [self.webView loadRequest:request];
}


-(void)toggleClose{
    NSError *returnError;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:@"Websession Dismissed" forKey:NSLocalizedDescriptionKey];
    returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAuthenticatedWebsessionDismissed userInfo:userInfo];
    [self dismissWithError:returnError];
    self.failure(returnError);
}

-(void)dismissWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self.failure(error);
            [self.webView removeFromSuperview];
            self.webView = nil;
        }];
    });
}

#pragma mark WEBPOLICYDELEGATE

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.webView == webView) {
        NSString* url = [[navigationAction.request URL] description];
        
        NSString *scheme = [[navigationAction.request URL] scheme];
        
        NSRange rangeOfScheme = [[ZIAMUtil sharedUtil]->UrlScheme rangeOfString:scheme];
        
        if (rangeOfScheme.length != 0)
        {
            NSError *returnError;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:url forKey:@"redirect_info"];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAuthenticatedWebsessionRedirected userInfo:userInfo];
            [self dismissWithError:returnError];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
#endif
