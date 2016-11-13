//
//  UBFIRDatabaseManager.m
//  
//
//  Created by Ricardo Nazario on 10/29/16.
//
//

#import "UBFIRDatabaseManager.h"

@import Firebase;

@interface UBFIRDatabaseManager ()

@property (nonatomic) FIRDatabaseHandle refHandle;

@end

@implementation UBFIRDatabaseManager

+ (FIRDatabaseReference *)databaseRef {
    return [[FIRDatabase database] reference];
}

+ (void)getAllValuesFromNode:(NSString *)node withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler {
    
    FIRDatabaseHandle refHandle;
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [ref child:node];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    refHandle = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        [results addObject:snapshot];
        
        if (successHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler ([self mapResults:results]);
            });
            [ref removeObserverWithHandle:refHandle];
        }
    } withCancelBlock:^(NSError *error) {
        
        if (errorHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorHandler (error);
            });
            [ref removeObserverWithHandle:refHandle];
        }
    }];
}

+(void)getAllValuesFromNode:(NSString *)node orderedBy:(NSString *)orderBy filteredBy:(NSString *)filter withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler {
    
    FIRDatabaseHandle refHandle;
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [ref child:node];
    FIRDatabaseQuery *query;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    query = [[ref queryOrderedByChild:orderBy] queryEqualToValue:filter];

    refHandle = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        [results addObject:snapshot];
        
        if (successHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler ([self mapResults:results]);
            });
            [ref removeObserverWithHandle:refHandle];
        }
    } withCancelBlock:^(NSError *error) {
        
        if (errorHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorHandler (error);
            });
            [ref removeObserverWithHandle:refHandle];
        }
    }];
}

+ (BOOL)checkIfNodeHasChild:(NSString *)node child:(NSString *)child {
    
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [ref child:node];
    
    __block BOOL hasChild;

    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot hasChild:child]) {
            
            NSLog(@"Children exist!");
            hasChild = YES;
        } else {
            
            NSLog(@"Children don't exist");
            hasChild = NO;
        }
    }];
    
    return hasChild;
}

+(void)createNode:(NSString *)node withValue:(NSString *)value forKey:(NSString *)key {
    
    FIRDatabaseReference *ref = [self databaseRef];
    
    [[[[ref child:node] childByAutoId] child:key] setValue:value];
}

+(void)createUnitOrSuperUnit:(NSString *)node withValue:(NSString *)value withOwner:(NSString *)owner {
    
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [[ref child:node] childByAutoId];
    
    [[ref child:@"name"] setValue:value];
    [[ref child:@"owner"] setValue:owner];
}

+(NSString *)getCurrentUser {
    return [FIRAuth auth].currentUser.uid;
}

+ (NSArray *)mapResults:(NSArray *)results {
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
        FIRDataSnapshot *snapshot = obj;
        NSString *name = snapshot.value[@"name"];
            
        NSDictionary <NSString *, NSString *> *snapshotDict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", snapshot.key, @"key", nil];
        [temp addObject: snapshotDict];
    }];
    
    return [NSArray arrayWithArray:temp];
}

@end
