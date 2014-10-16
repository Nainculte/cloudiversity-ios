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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
