//
//  AgendaTeacherClassViewController.h
//  Cloudiversity
//
//  Created by Nainculte on 20/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "AbstractTableViewController.h"

@interface AgendaTeacherClassViewController : AbstractTableViewController

@property (nonatomic, strong) NSString *disciplineTitle;
@property (nonatomic, strong) NSString *classTitle;
@property (nonatomic) int disciplineID;
@property (nonatomic) int classID;

@end