//
//  ZSSODCLUtil.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZSSODCLUtil.h"
#import "ZIAMUtilConstants.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"

@implementation ZIAMUtil(ZSSODCLUtil)


//Transform URL Handling
-(NSString *)getTransformedURLStringForURL:(NSString *)url{
    return [self transformURL:url AppName:AppName forZuid:[self getCurrentUserZUIDFromKeychain]];
}
-(NSString *)getTransformedURLStringForURL:(NSString *)url forZuid:(NSString *)zuid{
    return [self transformURL:url AppName:AppName forZuid:zuid];
}

-(NSString *)getDCLLocationForZUID:(NSString *)zuid havingappName:(NSString *)appName{
    NSString *dclLocation;
    if (([[ZIAMUtil sharedUtil] getIsSignedInUsingSSOAccountForZUID:zuid]) || ([[ZIAMUtil sharedUtil] checkifSSOAccountsMatchForZUID:zuid])){
        dclLocation = [self getSSODCLLocationFromSharedKeychainForZUID:zuid];
    } else {
        dclLocation = [self getDCLLocationFromKeychainForZUID:zuid];
    }
    return dclLocation;
}
-(NSData *)getDCLMetaForZUID:(NSString *)zuid havingappName:(NSString *)appName{
    NSData *bas64Data;
    if (([[ZIAMUtil sharedUtil] getIsSignedInUsingSSOAccountForZUID:zuid]) || ([[ZIAMUtil sharedUtil] checkifSSOAccountsMatchForZUID:zuid])){
        bas64Data= [self getSSODCLMetaFromSharedKeychainForZUID:zuid];
    } else {
        bas64Data= [self getDCLMetaFromKeychainForZUID:zuid];
    }
    return bas64Data;
}

-(NSString *)transformURL:(NSString *)url AppName:(NSString *)appName forZuid:(NSString *)zuid{
    
    NSString *dclLocation = [self getDCLLocationForZUID:zuid havingappName:appName];
    if(dclLocation){
        return [self transformURL:url ZUID:zuid Location:dclLocation havingappName:appName];
    }else{
        return url;
    }
}
-(NSDictionary *)getDCLInfoForCurrentUser{
    return [self getDCLInfoForZuid:[self getCurrentUserZUIDFromKeychain]];
}

-(NSDictionary *)getDCLInfoForZuid:(NSString *)zuid{
    NSString *dclLocation = [self getDCLLocationForZUID:zuid havingappName:AppName];
    NSData *bas64Data = [self getDCLMetaForZUID:zuid havingappName:AppName];
    if(!dclLocation || !bas64Data){
        //Fixup for OneAuth initial version case where there won't be dcl data in shared keychain and those users are defenitely US DC.
        NSMutableDictionary *defaultTarget = [[NSMutableDictionary alloc] init];
        [defaultTarget setValue:@"zoho.com" forKey:@"basedomain"];
        [defaultTarget setValue:@"United States" forKey:@"description"];
        [defaultTarget setValue:@"" forKey:@"equivalent_basedomains"];
        [defaultTarget setValue:@"0" forKey:@"is_prefixed"];
        [defaultTarget setValue:@"us" forKey:@"location"];
        [defaultTarget setValue:@"https://accounts.zoho.com" forKey:@"server_url"];
        return defaultTarget;
    }
    
    NSError *jsonError = nil;
    NSArray *JSONArray = [NSJSONSerialization JSONObjectWithData:bas64Data options:kNilOptions error:&jsonError];
    
    NSDictionary *TargetJSONDictionary = [[NSDictionary alloc] init];
    for (int i =0; i<[JSONArray count]; i++) {
        NSDictionary *JSONDictionary = JSONArray[i];
        NSString*location = [JSONDictionary valueForKey:@"location"];
        if([location isEqualToString:dclLocation]){
            TargetJSONDictionary = JSONDictionary;
            break;
        }
    }
    return TargetJSONDictionary;
}

-(NSString *)transformURL:(NSString *)url ZUID:(NSString *)zuid Location:(NSString *)dclLocation{
    return [self transformURL:url ZUID:zuid Location:dclLocation havingappName:AppName];
}

-(NSString *)transformURL:(NSString *)url ZUID:(NSString *)zuid Location:(NSString *)dclLocation havingappName:(NSString *)appName{
  
    NSData *bas64Data = [self getDCLMetaForZUID:zuid havingappName:appName];
    if(!bas64Data)
        return url;
    
    NSError *jsonError = nil;
    NSArray *JSONArray = [NSJSONSerialization JSONObjectWithData:bas64Data options:kNilOptions error:&jsonError];
    
    NSDictionary *TargetJSONDictionary = [[NSDictionary alloc] init];
    for (int i =0; i<[JSONArray count]; i++) {
        NSDictionary *JSONDictionary = JSONArray[i];
        NSString*location = [JSONDictionary valueForKey:@"location"];
        if([location isEqualToString:dclLocation]){
            TargetJSONDictionary = JSONDictionary;
            break;
        }
    }
    
    NSNumber *isPrefixed =(NSNumber *)[TargetJSONDictionary objectForKey:@"is_prefixed"];
    
    NSString * transformedURL = url;
    NSString *oldPrefix = @"";
    
    BOOL isDomainKnown = false;
    BOOL isWWWDomain = false;
    
    
    NSString *scheme = @"https://";
    
    if ([transformedURL hasPrefix:@"http:"]){
        
        scheme = @"http://";
        
    }
    
    // Remove scheme from URL
    
    if([transformedURL hasPrefix:@"http:"] || [transformedURL hasPrefix:@"https:"]){
        NSString *original;
        if([transformedURL hasPrefix:@"http:"]){
            original = @"http://";
        }else{
            original = @"https://";
        }
        NSString *replacement = @"";
        NSRange rOriginal = [transformedURL rangeOfString: original];
        if (NSNotFound != rOriginal.location) {
            transformedURL = [transformedURL
                              stringByReplacingCharactersInRange: rOriginal
                              withString:                         replacement];
        }
    }
    
//    if([transformedURL hasPrefix:@"www."]){
//
//        isWWWDomain = true;
//        NSString *original = @"www.";
//        NSString *replacement = @"";
//        NSRange rOriginal = [transformedURL rangeOfString: original];
//        if (NSNotFound != rOriginal.location) {
//            transformedURL = [transformedURL
//                              stringByReplacingCharactersInRange: rOriginal
//                              withString:                         replacement];
//        }
//    }
    
    // Identify white-listed location/dcl prefix
    BOOL isWhiteListedPrefix = false;
    NSArray *prefixArray = [transformedURL componentsSeparatedByString: @"-"];
    NSString *prefix = prefixArray[0];
    for (int i =0; i<[JSONArray count]; i++) {
        NSDictionary *JSONDictionary = JSONArray[i];
        if([prefix isEqualToString:[JSONDictionary valueForKey:@"location"]]){
            isWhiteListedPrefix = true;
            break;
        }
    }
    if ([transformedURL rangeOfString:@"-"].location != NSNotFound && isWhiteListedPrefix) {
        
        oldPrefix = prefix;
        
        NSRange range1 = [transformedURL rangeOfString:prefix];
        range1.length = range1.length+1;
        transformedURL = [transformedURL
                          stringByReplacingCharactersInRange:range1
                          withString:@""];
        
    }
    
    NSString *domain = transformedURL;
    
    NSString *path = nil;
    NSString *qs = nil;
    
    
    
    // Split service url/path from domain
    
    //if ([transformedURL rangeOfString:@"/"].location == NSNotFound) {// No I18N
    if ([transformedURL containsString:@"/"]) {// No I18N
        int range = (int)[transformedURL rangeOfString:@"/"].location;
        domain = [transformedURL substringWithRange:NSMakeRange(0, range)];
        path = [transformedURL substringWithRange:NSMakeRange(range, [transformedURL length]-range)];
    }
    
    //Resolving Query String
    if([domain containsString:@"?"]){
        int range = (int)[transformedURL rangeOfString:@"?"].location;
        domain = [transformedURL substringWithRange:NSMakeRange(0, range)];
        qs = [transformedURL substringWithRange:NSMakeRange(range, [transformedURL length]-range)];
    }
    
    
    //Replace zoho.com or zoho.eu or zoho.in to required string from json
    
    for(int i=0;i<[JSONArray count];i++){
        NSDictionary *JSONDictionary = JSONArray[i];
        NSString *baseDomain = [JSONDictionary valueForKey:@"basedomain"];
        if([domain hasSuffix:baseDomain]){
            NSString *replacement = [TargetJSONDictionary objectForKey:@"basedomain"];
            NSRange rOriginal = [domain rangeOfString: baseDomain];
            if (NSNotFound != rOriginal.location) {
                domain = [domain
                          stringByReplacingCharactersInRange: rOriginal
                          withString:                         replacement];
                if([domain isEqualToString:replacement]){
                    if([isPrefixed boolValue]){
                        domain = [NSString stringWithFormat:@"%@.%@",replacement,domain];
                    }
                }else{
                    isDomainKnown = true;
                }
            }
            break;
        }else if ([JSONDictionary objectForKey:@"equivalent_basedomains"] && [[JSONDictionary objectForKey:@"equivalent_basedomains"] length]>0){
            NSString *ebds = [JSONDictionary objectForKey:@"equivalent_basedomains"];
            NSArray *ebdsArray = [ebds componentsSeparatedByString: @","];
            NSString *ebdregex = @"";
            NSString *domainregex = @"";
            for (id ebd in ebdsArray) {
                NSString *replacedEbd = [ebd stringByReplacingOccurrencesOfString: @"." withString:@"\\."];
                ebdregex = [NSString stringWithFormat:@"%@([^.]*%@$)|",ebdregex,replacedEbd];
                domainregex = [NSString stringWithFormat:@"%@(.*%@$)|",domainregex,replacedEbd];
            }
            if([ebdregex length]>0 ){
                ebdregex = [ebdregex substringToIndex:[ebdregex length]-1];
                domainregex = [domainregex substringToIndex:[domainregex length]-1];
                NSError *err;
                NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:domainregex options:0 error:&err];
                NSTextCheckingResult *match = [regex firstMatchInString:domain options:0 range:NSMakeRange(0, [domain length])];
                if([match numberOfRanges]>0){
                    NSRegularExpression *regexsd = [[NSRegularExpression alloc] initWithPattern:ebdregex options:0 error:NULL];
                    NSTextCheckingResult *matchsd = [regexsd firstMatchInString:domain options:0 range:NSMakeRange(0, [domain length])];
                    if([matchsd numberOfRanges]>0){
                        NSString *subDomain = [domain stringByReplacingCharactersInRange:[matchsd range] withString:@""];
                        NSRange rOriginal = [domain rangeOfString: subDomain];
                        if (NSNotFound != rOriginal.location) {
                            NSString *tld = [domain
                                             stringByReplacingCharactersInRange: rOriginal
                                             withString:@""];
                            NSString *replacementDomain = @"";
                            NSArray *dCCustomDomains = [TargetJSONDictionary valueForKey:@"dCCustomDomains"];
                            for (NSDictionary *ebd in dCCustomDomains) {
                                NSString *orbd = [ebd valueForKey:@"original_basedomain"];
                                if ([tld isEqualToString:orbd]) {
                                    replacementDomain = [ebd valueForKey:@"transformed_basedomain"];
                                    break;
                                }
                            }
                            if ([replacementDomain length] > 0) {
                                domain = [NSString stringWithFormat:@"%@%@",subDomain,replacementDomain];
                                isDomainKnown = true;
                            }else{
                                domain = [NSString stringWithFormat:@"%@%@",subDomain,tld];
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
    
    // construct final transformed URL
    
    transformedURL = [NSString stringWithFormat:@"%@",scheme];
    if(isWWWDomain){
        transformedURL = [NSString stringWithFormat:@"%@www.",transformedURL];
    }
    
    
    
    if(isDomainKnown && [isPrefixed boolValue] ){
        transformedURL = [NSString stringWithFormat:@"%@%@-",transformedURL,[TargetJSONDictionary objectForKey:@"location"]];
    }else{
        if(!isDomainKnown){
            transformedURL = [NSString stringWithFormat:@"%@%@",transformedURL,oldPrefix];
        }
    }
    transformedURL = [NSString stringWithFormat:@"%@%@",transformedURL,domain];
    if(path!=nil){
        transformedURL = [NSString stringWithFormat:@"%@%@",transformedURL,path];
    }
    if(qs!=nil){
        transformedURL = [NSString stringWithFormat:@"%@%@",transformedURL,qs];
    }
    DLog(@"Final Transformed URL : %@",transformedURL);
    return transformedURL;
}
@end
