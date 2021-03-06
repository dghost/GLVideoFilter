#import "FilterManager.h"

static bool _initialized = false;
static NSArray *_filterList = nil;

@implementation FilterManager

#pragma mark - Class Methods

+(void)loadFilters
{
    if (!_initialized)
    {
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"Filters" ofType:@"plist"];
        NSArray *filters = [NSArray arrayWithContentsOfFile:plist];
        NSMutableArray *tempFilterList = [NSMutableArray array];
        for (NSDictionary *filter in filters)
        {
#if defined(DEBUG)
            NSString *name = [filter objectForKey:@"Name"];
            NSArray *passes = [filter objectForKey:@"Passes"];
            NSLog(@"Found filter '%@' with %lu passes",name,[passes count]);
#endif
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

#pragma mark - Instance Methods and Variables

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
    NSArray *filter = [[_filterList objectAtIndex:currentFilter] objectForKey:@"Passes"];
    if (filter == nil)
        return [NSArray array];
    return filter;
}

-(NSString*)getCurrentName
{
    NSString *name = [[_filterList objectAtIndex:currentFilter] objectForKey:@"Name"];
    if (name == nil)
        return @"";
    return name;
}

-(void)setFilterByName:(NSString *)name
{
    if (name == nil || [name isEqualToString:@""])
        currentFilter = 0;
    for (int i = 0; i < [_filterList count]; i++)
    {
        if ([name isEqualToString:[[_filterList objectAtIndex:i]  objectForKey:@"Name"]])
            currentFilter = i;
    }
}


@end
