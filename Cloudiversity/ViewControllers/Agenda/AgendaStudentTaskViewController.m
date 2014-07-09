//
//  AgendaStudentTaskViewController.m
//  Cloudiversity
//
//  Created by Anthony MERLE on 10/06/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaStudentTaskViewController.h"
#import "AgendaAssignment.h"
#import "UICloud.h"
#import "CloudDateConverter.h"
#import "AMPieChartView.h"
#import "UIColor+Cloud.h"
#import "IOSRequest.h"
#import "DejalActivityView.h"

#define DICO_ID					@"id"
#define DICO_TITLE				@"title"
#define DICO_PROGRESS			@"progress"
#define DICO_DEADLINE			@"deadline"
#define DICO_DUETIME 			@"duetime"
#define DICO_WORDING 			@"wording" // This is the description of the assignment
#define DICO_CREATED_AT 		@"created_at"
#define DICO_UPDATE_AT 			@"updated_at"
#define DICO_DISCIPLINE 		@"discipline"
#define DICO_DISCIPLINE_ID			@"id"
#define DICO_DISCIPLINE_NAME		@"name"
#define DICO_SCHOOL_CLASS 		@"school_class"
#define DICO_SCHOOL_CLASS_ID		@"id"
#define DICO_SCHOOL_CLASS_NAME		@"name"

@interface AgendaStudentTaskViewController ()

@property (weak, nonatomic) IBOutlet CloudLabel *workTitleLabel;
@property (weak, nonatomic) IBOutlet AMPieChartView *pieChartView;
@property (weak, nonatomic) IBOutlet CloudLabel *givenOnLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *givenDateLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueToLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dueToDateLabel;
@property (weak, nonatomic) IBOutlet CloudLabel *dissiplineNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *assignmentDescriptionTextView;
@property (weak, nonatomic) IBOutlet UISlider *progressBarInput;

@property (nonatomic, strong) AgendaAssignment *assignment;

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
	[self initAssignment];
	
	[self.pieChartView setInternalColor:[UIColor cloudLightBlue]];
	[self.pieChartView setExternalColor:[UIColor cloudBlue]];
	[self.workTitleLabel setFont:[UIFont fontWithName:CLOUD_FONT_BOLD size:self.workTitleLabel.font.pointSize]];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - testDatas

#define SAVING_PLACE_ASSIGNMENT	@"agendaTmpPlaceForAssignment"

- (void)initAssignment {
	NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
	NSData *data = [uDefault objectForKey:SAVING_PLACE_ASSIGNMENT];
	self.assignment = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *response = (NSDictionary *)responseObject;

		self.assignment.progress = [[response objectForKey:DICO_PROGRESS] intValue];
		self.assignment.assignmentDescription = [response objectForKey:DICO_WORDING];
		self.assignment.creationDate = [[CloudDateConverter sharedMager] dateAndTimeFromString:[response objectForKey:DICO_CREATED_AT]];
		if (self.assignment.creationDate == nil)
			self.assignment.creationDate = [[CloudDateConverter sharedMager] dateAndTimeWithSecondsFromString:[response objectForKey:DICO_CREATED_AT]];
		self.assignment.lastUpdate = [[CloudDateConverter sharedMager] dateAndTimeFromString:[response objectForKey:DICO_UPDATE_AT]];
		if (self.assignment.lastUpdate == nil)
			self.assignment.lastUpdate = [[CloudDateConverter sharedMager] dateAndTimeWithSecondsFromString:[response objectForKey:DICO_UPDATE_AT]];
		
		self.workTitleLabel.text = self.assignment.title;
		self.assignmentDescriptionTextView.text = self.assignment.assignmentDescription;
		self.pieChartView.percentage = self.assignment.progress;
		if ([[[CloudDateConverter sharedMager] stringFromTime:self.assignment.dueDate] isEqualToString:@"00:00"]) {
			self.dueToDateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDate:self.assignment.dueDate];
		} else {
			self.dueToDateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDateAtTime:self.assignment.dueDate];
		}
		self.givenDateLabel.text = [[CloudDateConverter sharedMager] stringFromFullDateAtTime:self.assignment.creationDate];
		self.dissiplineNameLabel.text = [self.assignment.dissiplineInformation objectForKey:DICO_DISCIPLINE_NAME];
		
		[self.progressBarInput setValue:self.assignment.progress];
		[self.progressBarInput addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
		[self.progressBarInput addTarget:self action:@selector(updateProgressAfterDragingSlider:) forControlEvents:UIControlEventTouchUpInside];
	};
	void (^failure)(AFHTTPRequestOperation *, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        switch (operation.response.statusCode) {
            default:
                break;
        }
	};
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
	[IOSRequest getAssignmentInformation:self.assignment.assignmentId onSuccess:success onFailure:failure];
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

- (void)sliderValueChanged:(UISlider*)slider {
	self.pieChartView.percentage = slider.value;
}

- (void)updateProgressAfterDragingSlider:(UISlider*)slider {
	void (^success)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
		NSDictionary *response = (NSDictionary*)responseObject;
		
		self.pieChartView.percentage = [[response objectForKey:DICO_PROGRESS] intValue];
		self.assignment.progress = [[response objectForKey:DICO_PROGRESS] intValue];
	};
	void (^failure)(AFHTTPRequestOperation *, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        switch (operation.response.statusCode) {
            default:
                break;
        }
	};
	[DejalActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
	[IOSRequest updateAssignmentWithId:self.assignment.assignmentId withProgression:slider.value onSuccess:success onFailure:failure];
}

@end
