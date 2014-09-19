//
//  CloudTableViewDelegate.h
//  Cloudiversity
//
//  Created by Nainculte on 13/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CloudTableViewDelegate <NSObject, UITableViewDelegate>

@optional
- (void)tableViewWillReloadData:(UITableView *)tableView;
- (void)tableViewDidReloadData:(UITableView *)tableView;

@end
