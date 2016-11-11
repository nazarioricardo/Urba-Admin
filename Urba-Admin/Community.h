//
//  CurrentCommunity.h
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/11/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct Community {
    __unsafe_unretained NSString *identifier;
    __unsafe_unretained NSString *communityName;
    __unsafe_unretained NSString *adminName;
    __unsafe_unretained NSString *email;
} Community;

@interface CurrentCommunity : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *communityName;
@property (nonatomic, copy, readonly) NSString *adminName;
@property (nonatomic, copy, readonly) NSString *email;

- (instancetype)initWithInputData:(id)inputData;

@end
