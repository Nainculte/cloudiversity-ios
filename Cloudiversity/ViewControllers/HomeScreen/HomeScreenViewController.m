//
//  HomeScreenViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 18/04/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "HomeScreenViewController.h"

#define LOCALIZEDSTRING(s) [[NSBundle mainBundle] localizedStringForKey:s value:@"Localization error" table:@"HomeScreenVC"]

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LOCALIZEDSTRING(@"TITLE");
}

@end
