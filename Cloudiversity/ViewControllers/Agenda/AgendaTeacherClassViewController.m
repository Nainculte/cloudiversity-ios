//
//  AgendaTeacherClassViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 20/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaTeacherClassViewController.h"

@interface AgendaTeacherClassViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

@end

@implementation AgendaTeacherClassViewController

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

    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self setupTitle];

}

- (void)setupTitle
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 136, 44)];
    view.backgroundColor = [UIColor clearColor];

    UILabel *discipline = [[UILabel alloc] initWithFrame:CGRectMake(0, (view.frame.size.height * 2/3) - 8, view.frame.size.width, (view.frame.size.height / 3) + 4)];
    discipline.backgroundColor = [UIColor clearColor];
    discipline.text = self.disciplineTitle;
    discipline.textColor = [UIColor whiteColor];
    discipline.textAlignment = NSTextAlignmentCenter;
    [view addSubview:discipline];

    UILabel *class = [[UILabel alloc] initWithFrame:CGRectMake(0, -4, view.frame.size.width, view.frame.size.height * 2/3)];
    class.backgroundColor = [UIColor clearColor];
    class.text = self.classTitle;
    class.textColor = [UIColor whiteColor];
    class.textAlignment = NSTextAlignmentCenter;
    class.font = [UIFont boldSystemFontOfSize: 17.0];
    [view addSubview:class];

    self.navigationItem.titleView = view;
}

- (void)setupHandlers
{
    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
    };
    self.failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
