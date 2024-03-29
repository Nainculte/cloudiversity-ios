//
//  AbstractViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 7/9/14.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractViewController.h"

@interface AbstractViewController ()

@end

@implementation AbstractViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor cloudGrey];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor cloudLightBlue]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor cloudLightBlue]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	
	if (self.showMenuButton) {
		UIImage *barButtonImage = [UIImage imageNamed:@"menu.png"];
		self.leftButton = [[UIBarButtonItem alloc] initWithImage:barButtonImage style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
		self.navigationController.navigationBar.topItem.leftBarButtonItem = self.leftButton;
	}
}

- (void)setRightViewController:(NSString *)name withButton:(UIBarButtonItem *)button
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    self.revealViewController.rightViewController = [sb instantiateViewControllerWithIdentifier:name];
    if (button) {
        button.target = self.revealViewController;
        button.action = @selector(rightRevealToggle:);
    }
}

- (void)setRightViewController:(NSString *)name
{
    [self setRightViewController:name withButton:nil];
}

@end
