//
//  UBFIRDatabaseManager.h
//  
//
//  Created by Ricardo Nazario on 10/29/16.
//
//

#import <Foundation/Foundation.h>
#import "Community.h"


typedef void(^FIRSuccessHandler)(NSArray *results);
typedef void(^FIRErrorHandler)(NSError *error);
typedef void(^FIRCommHandler)(Community *community);

@interface UBFIRDatabaseManager : NSObject

+(void)getAllValuesFromNode:(NSString *)node withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;
+(void)getAllValuesFromNode:(NSString *)node orderedBy:(NSString *)orderBy filteredBy:(NSString *)filter withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;
+(void)getAllValuesFromSingleNode:(NSString *)node orderedBy:(NSString *)order filteredBy:(NSString *)filter withHandler:(FIRCommHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;
+(void)createNode:(NSString *)node withValue:(NSString *)value forKey:(NSString *)key;
+(NSString *)getCurrentUser;

@end
