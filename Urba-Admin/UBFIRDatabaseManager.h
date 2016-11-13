//
//  UBFIRDatabaseManager.h
//  
//
//  Created by Ricardo Nazario on 10/29/16.
//
//

#import <Foundation/Foundation.h>


typedef void(^FIRSuccessHandler)(NSArray *results);
typedef void(^FIRErrorHandler)(NSError *error);

@interface UBFIRDatabaseManager : NSObject

+(void)getAllValuesFromNode:(NSString *)node withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;
+(void)getAllValuesFromNode:(NSString *)node orderedBy:(NSString *)orderBy filteredBy:(NSString *)filter withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;
+(BOOL)checkIfNodeHasChild:(NSString *)node child:(NSString *)child;
+(void)createNode:(NSString *)node withValue:(NSString *)value forKey:(NSString *)key;
+(void)createUnitOrSuperUnit:(NSString *)node withValue:(NSString *)value withOwner:(NSString *)owner;
+(NSString *)getCurrentUser;

@end
