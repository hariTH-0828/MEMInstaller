//
//  SSOKeyChainWrapper.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 8/20/15.
//  Copyright (c) 2015 Zoho. All rights reserved.
//


#import "SSOKeyChainWrapper.h"
#import "ZIAMUtilConstants.h"
#import "ZIAMUtil.h"

static NSString *_defaultService;

@interface SSOKeyChainWrapper () {
    NSMutableDictionary *itemsToUpdate;
}

@end

@implementation SSOKeyChainWrapper

+ (NSString *)defaultService
{
    if (!_defaultService) {
        _defaultService = kServiceKeychainItem;
    }
    return _defaultService;
}

+ (void)setDefaultService:(NSString *)defaultService
{
    _defaultService = defaultService;
}

#pragma mark -

+ (SSOKeyChainWrapper *)keyChainStore
{
    return [[self alloc] initWithService:[self defaultService]];
}

- (instancetype)init
{
    return [self initWithService:[self.class defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

- (instancetype)initWithService:(NSString *)service
{
    return [self initWithService:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup
{
    self = [super init];
    if (self) {
        if (!service) {
            service = [self.class defaultService];
        }
        _service = [service copy];
        _accessGroup = [accessGroup copy];
        
        itemsToUpdate = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark -

+ (NSString *)stringForKey:(NSString *)key
{
    return [self stringForKey:key service:[self defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service
{
    return [self stringForKey:key service:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSData *data = [self dataForKey:key service:service accessGroup:accessGroup];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key
{
    BOOL __block flag;
        flag =  [self setString:value forKey:key service:[self defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
    return flag;
    
}

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service
{
    
    return [self setString:value forKey:key service:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self setData:data forKey:key service:service accessGroup:accessGroup];
}

+ (void)setBool:(BOOL)string forKey:(NSString *)key
{
    NSString * booleanString = (string) ? @"True" : @"False";
    NSData *SetData =[booleanString dataUsingEncoding:NSUTF8StringEncoding];
    if(SetData != nil){
        [self setData:SetData forKey:key];
    }
    
}

+ (void)setBool:(BOOL)string forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup{
    NSString * booleanString = (string) ? @"True" : @"False";
    NSData *SetData =[booleanString dataUsingEncoding:NSUTF8StringEncoding];
    if(SetData != nil){
        [self setData:SetData forKey:key service:service accessGroup:accessGroup];
    }
}

+ (BOOL)boolForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key];
    if (data) {
        NSString* booleanString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if([booleanString isEqualToString:@"True"]){
            return YES;
        }else{
            return NO;
        }
    }
    
    return NO;
}

+ (BOOL)boolForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup{
    NSData *data = [self dataForKey:key service:service accessGroup:accessGroup];
    if (data) {
        NSString* booleanString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if([booleanString isEqualToString:@"True"]){
            return YES;
        }else{
            return NO;
        }
    }
    
    return NO;
}

#pragma mark -

+ (NSData *)dataForKey:(NSString *)key
{
    return [self dataForKey:key service:[self defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service
{
    return [self dataForKey:key service:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    if (!key) {
        return nil;
    }
    if (!service) {
        service = [self defaultService];
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
    [query setObject:key forKey:(__bridge id)kSecAttrGeneric];
    [query setObject:key forKey:(__bridge id)kSecAttrAccount];
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    if (status != errSecSuccess) {
        return nil;
    }
    
    NSData *ret = [NSData dataWithData:(__bridge NSData *)data];
    if (data) {
        CFRelease(data);
    }
    
    return ret;
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key
{
    return [self setData:data forKey:key service:[self defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service
{
    return [self setData:data forKey:key service:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    if (!key) {
        return NO;
    }
    if (!service) {
        service = [self defaultService];
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
    [query setObject:key forKey:(__bridge id)kSecAttrGeneric];
    [query setObject:key forKey:(__bridge id)kSecAttrAccount];
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecSuccess) {
        if (data) {
            NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
            [attributesToUpdate setObject:data forKey:(__bridge id)kSecValueData];
            
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
            if (status != errSecSuccess) {
                return NO;
            }
        } else {
            [self removeItemForKey:key service:service accessGroup:accessGroup];
        }
    } else if (status == errSecItemNotFound) {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [attributes setObject:service forKey:(__bridge id)kSecAttrService];
        [attributes setObject:key forKey:(__bridge id)kSecAttrGeneric];
        [attributes setObject:key forKey:(__bridge id)kSecAttrAccount];
#if TARGET_OS_IPHONE || (defined(MAC_OS_X_VERSION_10_9) && MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9)
        [attributes setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
#endif
        [attributes setObject:data forKey:(__bridge id)kSecValueData];
        if (accessGroup) {
            [attributes setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
        
        status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        if (status != errSecSuccess) {
            return NO;
        }
    } else {
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (void)setString:(NSString *)string forKey:(NSString *)key
{
    [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (NSString *)stringForKey:(id)key
{
    NSData *data = [self dataForKey:key];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

#pragma mark -

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    if (!key) {
        return;
    }
    if (!data) {
        [self removeItemForKey:key];
    } else {
        [itemsToUpdate setObject:data forKey:key];
    }
}

- (NSData *)dataForKey:(NSString *)key
{
    NSData *data = [itemsToUpdate objectForKey:key];
    if (!data) {
        data = [[self class] dataForKey:key service:self.service accessGroup:self.accessGroup];
    }
    
    return data;
}

#pragma mark -

+ (BOOL)removeItemForKey:(NSString *)key
{
    return [SSOKeyChainWrapper removeItemForKey:key service:[self defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service
{
    return [SSOKeyChainWrapper removeItemForKey:key service:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    if (!key) {
        return NO;
    }
    if (!service) {
        service = [self defaultService];
    }
    
    NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] init];
    [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [itemToDelete setObject:service forKey:(__bridge id)kSecAttrService];
    [itemToDelete setObject:key forKey:(__bridge id)kSecAttrGeneric];
    [itemToDelete setObject:key forKey:(__bridge id)kSecAttrAccount];
    if (accessGroup) {
        [itemToDelete setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        return NO;
    }
    
    return YES;
}

+ (NSArray *)itemsForService:(NSString *)service accessGroup:(NSString *)accessGroup
{
    if (!service) {
        service = [self defaultService];
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
    if (accessGroup) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    CFArrayRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecSuccess || status == errSecItemNotFound) {
        return CFBridgingRelease(result);
    } else {
        return nil;
    }
}

+ (BOOL)removeAllItems
{
    return [self removeAllItemsForService:[self defaultService] accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)removeAllItemsForService:(NSString *)service
{
    return [self removeAllItemsForService:service accessGroup:[ZIAMUtil sharedUtil].ExtensionAppGroup];
}

+ (BOOL)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSArray *items = [SSOKeyChainWrapper itemsForService:service accessGroup:accessGroup];
    for (NSDictionary *item in items) {
        NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] initWithDictionary:item];
        [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
        if (status != errSecSuccess) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

- (void)removeItemForKey:(NSString *)key
{
    if ([itemsToUpdate objectForKey:key]) {
        [itemsToUpdate removeObjectForKey:key];
    } else {
        [[self class] removeItemForKey:key service:self.service accessGroup:self.accessGroup];
    }
}

- (void)removeAllItems
{
    [itemsToUpdate removeAllObjects];
    [[self class] removeAllItemsForService:self.service accessGroup:self.accessGroup];
}

#pragma mark -

- (void)synchronize
{
    for (NSString *key in itemsToUpdate) {
        [[self class] setData:[itemsToUpdate objectForKey:key] forKey:key service:self.service accessGroup:self.accessGroup];
    }
    
    [itemsToUpdate removeAllObjects];
}

#pragma mark -

- (NSString *)description
{
    NSArray *items = [SSOKeyChainWrapper itemsForService:self.service accessGroup:self.accessGroup];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (NSDictionary *attributes in items) {
        NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
        [attrs setObject:[attributes objectForKey:(__bridge id)kSecAttrService] forKey:@"Service"];
        [attrs setObject:[attributes objectForKey:(__bridge id)kSecAttrAccount] forKey:@"Account"];
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        [attrs setObject:[attributes objectForKey:(__bridge id)kSecAttrAccessGroup] forKey:@"AccessGroup"];
#endif
        NSData *data = [attributes objectForKey:(__bridge id)kSecValueData];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string) {
            [attrs setObject:string forKey:@"Value"];
        } else {
            [attrs setObject:data forKey:@"Value"];
        }
        [list addObject:attrs];
    }
    
    return [list description];
}

#pragma mark - Object Subscripting

- (NSString *)objectForKeyedSubscript:(NSString <NSCopying> *)key
{
    return [self stringForKey:key];
}

- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString <NSCopying> *)key
{
    [self setString:obj forKey:key];
}


@end
