#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface FilterManager : NSObject

+(void)loadFilters;
+(void)teardownFilters;
-(void)nextFilter;
-(void)prevFilter;
-(NSArray*)getCurrentFilter;
-(NSString*)getCurrentName;

@end
