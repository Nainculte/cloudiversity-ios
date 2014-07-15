//
//  AgendaTeacherViewController.m
//  Cloudiversity
//
//  Created by Nainculte on 14/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AgendaTeacherViewController.h"
#import "AgendaTeacherTableViewCell.h"

@interface AgendaTeacherViewController ()

@property (nonatomic, strong) HTTPSuccessHandler success;
@property (nonatomic, strong) HTTPFailureHandler failure;

- (IBAction)refresh:(id)sender;
@end

@implementation AgendaTeacherViewController

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

    [self setupHandlers];
    self.sections = [NSMutableDictionary dictionary];

    if ([[EGOCache globalCache] hasCacheForKey:@"disciplinesTeacher"]) {
        [self.tableView reloadData];
    } else {
        [self initAssignmentsByHTTPRequest];
    }
    // Do any additional setup after loading the view.
}

- (void)initAssignmentsByHTTPRequest
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading..."].showNetworkActivityIndicator = YES;
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (void)setupHandlers
{
    BSELF(self)
    self.success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *response = (NSArray *)responseObject;
        NSMutableDictionary *disciplines = [NSMutableDictionary dictionary];

        for (NSDictionary *discipline in response) {
            [disciplines setObject:discipline forKey:[discipline objectForKey:@"name"]];
        }
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:disciplines] forKey:@"disciplinesTeacher"];
        [[EGOCache globalCache] setData:[NSKeyedArchiver archivedDataWithRootObject:response] forKey:@"disciplinesArray"];
        bself.sections = disciplines;
        bself.sortedSections = response;
		[bself.tableView reloadData];
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
    self.failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        switch (operation.response.statusCode) {
            default:
                break;
        }
        [DejalActivityView removeView];
        [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:NO];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    [((CloudiversityAppDelegate *)[[UIApplication sharedApplication] delegate]) setNetworkActivityIndicatorVisible:YES];
    [IOSRequest getAssignmentsForUserOnSuccess:self.success onFailure:self.failure];
}

- (NSString *)reuseIdentifier
{
    return @"AgandaTeacherCell";
}

+ (Class)cellClass
{
    return [AgendaTeacherTableViewCell class];
}

#pragma mark - UITableView Delegate / DataSource

- (CGFloat)tableView:(UITableView *)tableView HeightForHeaderInSection:(NSInteger)section
{
    return 18;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    CloudLabel *label = [[CloudLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    NSString *headerTitle = [[self.sortedSections objectAtIndex:section] objectForKey:@"name"];
    label.text = headerTitle;
    [view addSubview:label];
    view.backgroundColor = [UIColor cloudGrey];
    return view;
}

- (void)setupCell:(UITableViewCell *)c withIndexPath:(NSIndexPath *)indexPath
{
    AgendaTeacherTableViewCell *cell = (AgendaTeacherTableViewCell *)c;

    cell.classLabel.text = [[[[self.sortedSections objectAtIndex:indexPath.section] objectForKey:@"school_classes"] objectAtIndex:indexPath.row] objectForKey:@"name"];
    int nbr = [[[[[self.sortedSections objectAtIndex:indexPath.section] objectForKey:@"school_classes"] objectAtIndex:indexPath.row] valueForKey:@"assignment_count"] intValue];
    if (nbr <= 1) {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%d assignment", nbr];
    } else {
        cell.assignmentsLabel.text = [NSString stringWithFormat:@"%d assignments", nbr];
    }
}

- (void)tableViewWillReloadData:(UITableView *)tableView
{
    if ([[EGOCache globalCache] hasCacheForKey:@"disciplinesTeacher"]) {
        NSMutableDictionary *disciplines = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"disciplinesTeacher"]];
        NSArray *disciplinesArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[EGOCache globalCache] dataForKey:@"disciplinesArray"]];
        if (disciplines && disciplinesArray) {
            self.sections = disciplines;
            self.sortedSections = disciplinesArray;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.sortedSections objectAtIndex:section] objectForKey:@"school_classes"] count];
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
