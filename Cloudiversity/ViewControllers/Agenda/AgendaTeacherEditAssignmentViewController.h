//
//  AgendaTeacherEditAssignmentViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 22/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UINavigationController.h>
#import "XLForm.h"
#import "UIColor+Cloud.h"
#import "AgendaAssignment.h"
#import "AgendaTeacherClassViewController.h"

@interface AgendaTeacherEditAssignmentViewController : UINavigationController

- (id)initWithDisciplineID:(int)disciplineID withClassID:(int)classID andAssignment:(AgendaAssignment *)assignment presenter:(AgendaTeacherClassViewController *)presenter;

@property (nonatomic, assign) AgendaAssignment *assignment;

@property (nonatomic, assign) AgendaTeacherClassViewController *presenter;

@property (nonatomic) int disciplineID;
@property (nonatomic) int classID;

@end

@interface AgendaTeacherEditFormViewController : XLFormViewController

@property (nonatomic, retain) AgendaAssignment *assignment;

@property (nonatomic, assign) AgendaTeacherClassViewController *superPresenter;

@property (nonatomic) int disciplineID;
@property (nonatomic) int classID;

- (void)postInit;

- (id)initAdd;
- (id)initEdit;

#define BSELF(ptr) __weak typeof(ptr) bself = ptr;

@end