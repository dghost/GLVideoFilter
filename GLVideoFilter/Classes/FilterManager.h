#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface FilterManager : NSObject

#pragma mark - Class Interface

+(void)loadFilters;
+(void)teardownFilters;

#pragma mark - Instance Interface

-(void)nextFilter;
-(void)prevFilter;
-(NSArray*)getCurrentFilter;
-(NSString*)getCurrentName;
-(void)setFilterByName:(NSString *)name;
@end
