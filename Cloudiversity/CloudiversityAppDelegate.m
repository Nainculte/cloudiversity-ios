//
//  CloudiversityAppDelegate.m
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudiversityAppDelegate.h"
#import "CloudKeychainManager.h"
#import "User.h"
#import "ServerViewController.h"
#import "NetworkManager.h"

@implementation CloudiversityAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    User *user = [User sharedUser];
    if (!user) {
        _window.rootViewController = [[ServerRootViewController alloc] init];
    } else if ((user.token = [CloudKeychainManager retrieveTokenWithEmail:user.email])) {
        [NetworkManager manager].loggedIn = YES;
        _window.rootViewController = [_window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"RevealViewController"];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[User sharedUser] saveUser];
    [[NetworkManager manager] stopMonitoringReachability];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"server"])
        [[NetworkManager manager] startMonitoringReachability];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[User sharedUser] saveUser];
    [[NetworkManager manager] stopMonitoringReachability];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    if (NumberOfCallsToSetVisible < 0)
        NumberOfCallsToSetVisible = 0;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

@end
