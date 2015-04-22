//
//  AppDelegate.m
//  Evolve
//
//  Created by Mike on 3/23/15.
//  Copyright (c) 2015 Mike Amaral. All rights reserved.
//

#import "AppDelegate.h"
#import "WeaselProgramViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[WeaselProgramViewController new]];

    [self.window makeKeyAndVisible];

    return YES;
}

@end
