//
//  JPSAppDelegate.m
//  Collection View Animation Bug
//
//  Created by Jean-Pierre Simard on 6/14/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import "JPSAppDelegate.h"
#import "JPSCollectionViewController.h"

@implementation JPSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = [[JPSCollectionViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
