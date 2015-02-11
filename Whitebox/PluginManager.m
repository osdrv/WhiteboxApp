//
//  PluginManager.m
//  Whitebox
//
//  Created by Olegs on 19/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "PluginManager.h"

@implementation PluginManager {
    NSHashTable *plugins_;
}

static PluginManager* instance_;

+ (PluginManager *) instance {
    if (!instance_) {
        instance_ = [[self alloc] init];
    }
    
    return instance_;
}

+ (BOOL) isInited {
    return ([self instance]->plugins_ != nil);
}

+ (void) initPlugins:(NSDictionary *)settings {
    
    NSHashTable *plugins_ = [[NSHashTable alloc] init];
    
    for (NSString *plugin_name in settings) {
        
        NSDictionary *plugin_options = (NSDictionary*)[settings valueForKey:plugin_name];
        
        NSNumber *plugin_enabled = (NSNumber *)[plugin_options valueForKey:@PLUGIN_OPTS_KEY_ENABLED];
        
        if ([plugin_enabled isEqualToNumber:[NSNumber numberWithInt:0]]) {
            continue;
        }
        
        NSLog(@"Initing plugin: %@", plugin_name);
        
        Class klass = NSClassFromString(plugin_name);
        
        ReactorPlugin *plugin = [[klass alloc] initPluginWithOptions:plugin_options];
        
        [plugins_ addObject:plugin];
    }
    
    [self instance]->plugins_ = plugins_;
}

+ (NSHashTable *) plugins {
    return [self instance]->plugins_;
}

+ (void) registerFlyweight:(PMKPromise *(^)(Session *))block forEventID:(int)event_id {
    FlyweightPlugin *flyweight = [[FlyweightPlugin alloc] initWithBlock:block eventID:event_id];
    [[self instance]->plugins_ addObject:flyweight];
}

@end
