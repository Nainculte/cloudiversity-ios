//
//  AgendaStudentTaskViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaStudentTaskViewController.h"
#import "AgendaAssgment.h"
#import "UICloud.h"
#import "CloudDateConverter.h"
#import "AMPieChartView.h"
#import "UIColor+Cloud.h"

@interface AgendaStudentTaskViewController ()

@property (weak, nonatomic) IBOutlet CloudLabel *workTitleLabel;
@property (weak, nonatomic) IBOutlet AMPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet CloudLabel *givenOnLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *givenDateLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueToLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueToDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *assigmentDescriptionTextView;

@property (nonatomic, strong) AgendaAssgment *assigment;

@end

@implementation AgendaStudentTaskViewController

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
	[self initAssigment];
	
	[self.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[self.pieChartView setExternalColor:[UIColor cloudBlue]];
	[self.workTitleLabel setFont:[UIFont fontWithName:CLOUD_FONT_BOLD size:self.workTitleLabel.font.pointSize]];
	//[[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - testDatas

#define SAVING_PLACE_ASSIGMENT	@"agendaTmpPlaceForAssigment"

- (void)initAssigment {
	NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
	NSData *data = [uDefault objectForKey:SAVING_PLACE_ASSIGMENT];
	self.assigment = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	self.workTitleLabel.text = self.assigment.title;
	self.assigmentDescriptionTextView.text = self.assigment.assigmentDescription;
	self.pieChartView.percentage = self.assigment.percentageCompletion;
	self.dueToDateLabel.text = [[CloudDateConverter sharedMager] stringFromDateAtTime:self.assigment.dueDate];
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
