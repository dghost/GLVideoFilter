#import "FilterManager.h"

@implementation FilterManager

static bool _initialized = false;
static NSArray *_filterList = nil;

+(void)loadFilters
{
    if (!_initialized)
    {
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"Filters" ofType:@"plist"];
        NSArray *filters = [NSArray arrayWithContentsOfFile:plist];
        NSMutableArray *tempFilterList = [NSMutableArray array];
        for (NSDictionary *filter in filters)
        {
            NSString *name = [filter objectForKey:@"Name"];
            NSArray *passes = [filter objectForKey:@"Passes"];
            NSLog(@"Found filter '%@' with %lu passes",name,[passes count]);
            [tempFilterList addObject:filter];
        }
        _filterList = [NSArray arrayWithArray:tempFilterList];
        _initialized = true;
    }
}

+(void)teardownFilters
{
    _filterList = nil;
    _initialized = false;
}

NSUInteger currentFilter;

- (id)init {
    if (!_initialized)
        [FilterManager loadFilters];
    self = [super init];
    if (self)
    {
        currentFilter = 0;
    }
    return self;
}

-(void)nextFilter
{
    currentFilter++;
    if (currentFilter >= [_filterList count])
        currentFilter = 0;
}

-(void)prevFilter
{
    if (currentFilter == 0)
        currentFilter = [_filterList count] - 1;
    else
        currentFilter--;
}

-(NSArray*)getCurrentFilter
{
     return [[_filterList objectAtIndex:currentFilter] objectForKey:@"Passes"];
}

-(NSString*)getCurrentName
{
    return [[_filterList objectAtIndex:currentFilter] objectForKey:@"Name"];
}


@end
