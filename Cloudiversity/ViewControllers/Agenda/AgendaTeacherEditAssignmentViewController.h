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

- (instancetype)initWithDisciplineID:(NSInteger)disciplineID withClassID:(NSInteger)classID andAssignment:(AgendaAssignment *)assignment presenter:(AgendaTeacherClassViewController *)presenter;

@property (nonatomic, assign) AgendaAssignment *assignment;

@property (nonatomic, assign) AgendaTeacherClassViewController *presenter;

@property (nonatomic, assign) NSInteger disciplineID;
@property (nonatomic, assign) NSInteger classID;

@end

@interface AgendaTeacherEditFormViewController : XLFormViewController

@property (nonatomic, retain) AgendaAssignment *assignment;

@property (nonatomic, assign) AgendaTeacherClassViewController *superPresenter;

@property (nonatomic, assign) NSInteger disciplineID;
@property (nonatomic, assign) NSInteger classID;

- (void)postInit;

- (instancetype)initAdd;
- (instancetype)initEdit;

#define BSELF(ptr) __weak typeof(ptr) bself = ptr;

@end