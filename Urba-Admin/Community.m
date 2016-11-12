//
//  CurrentCommunity.m
//  Urba-Admin
//
//  Created by Ricardo Nazario on 11/11/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "Community.h"

@import Firebase;

const struct CommunityFields CommunityFields = {
    .identifier = @"identifier",
    .communityName = @"communityName",
    .adminName = @"adminName",
    .email = @"email",
    .adminId = @"adminId"
};

@implementation Community

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

    
    NSLog(@"object value: %@", object);

//    _identifier = [object.key valueForKeyPath:CommunityFields.identifier];
//    _communityName = [object.value[@"name"] valueForKeyPath:CommunityFields.communityName];
//    _adminName = [object.value[@"admin-name"] valueForKeyPath:CommunityFields.adminName];
//    _email = [object.value[@"admin-email"] valueForKeyPath:CommunityFields.email];
//    _adminId = [object.value[@"admin-id"] valueForKeyPath: CommunityFields.adminId];
}

@end
