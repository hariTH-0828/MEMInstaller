//
//  SSOKeyChainWrapper.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 8/20/15.
//  Copyright (c) 2015 Zoho. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface SSOKeyChainWrapper : NSObject

@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) NSString *accessGroup;

+ (NSString *)defaultService;
+ (void)setDefaultService:(NSString *)defaultService;

+ (SSOKeyChainWrapper *)keyChainStore;

- (instancetype)init;
+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key;

+ (NSData *)dataForKey:(NSString *)key;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key;

- (void)setString:(NSString *)string forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

+ (void)setBool:(BOOL)string forKey:(NSString *)key;
+ (void)setBool:(BOOL)string forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (BOOL)boolForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

- (void)setData:(NSData *)data forKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;

+ (NSArray *)itemsForService:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (BOOL)removeItemForKey:(NSString *)key;
+ (BOOL)removeAllItems;
- (void)removeItemForKey:(NSString *)key;
- (void)removeAllItems;
+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

- (void)synchronize;

// object subscripting

- (NSString *)objectForKeyedSubscript:(NSString <NSCopying> *)key;
- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString <NSCopying> *)key;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup
;

@end
