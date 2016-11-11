//
//  CurrentCommunity.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/11/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "CurrentCommunity.h"

@import Firebase;

const struct Community Community = {
    .identifier = @"id",
    .communityName = @"communityName",
    .adminName = @"adminName",
    .email = @"email"
};

@implementation CurrentCommunity

#pragma mark - Lifecycle

- (instancetype)initWithInputData:(id)inputData {
    self = [super init];
    if (self) {
        [self mapObject:inputData];
    }
    return self;
}

#pragma mark - Private

- (void)mapObject:(FIRDataSnapshot *)object {
    _identifier = [object valueForKeyPath:Community.identifier];
    _communityName = [object valueForKeyPath:Community.communityName];
    _adminName = [object valueForKeyPath:Community.adminName];
    _email = [object valueForKeyPath:Community.email];
}

@end
