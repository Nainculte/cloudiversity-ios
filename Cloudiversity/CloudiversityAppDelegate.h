//
//  CloudiversityAppDelegate.h
//  Cloudiversity
//
//  Created by Rémy Marty on 04/02/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudiversityAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

@end
