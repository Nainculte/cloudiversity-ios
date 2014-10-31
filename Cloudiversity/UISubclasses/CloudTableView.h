//
//  CloudTableView.h
//  Cloudiversity
//
//  Created by Nainculte on 13/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudTableViewDelegate.h"

@interface CloudTableView : UITableView {
    struct {
        NSUInteger delegateWillReloadData:1;
        NSUInteger delegateDidReloadData:1;
        NSUInteger reloading:1;
    } _flags;
}
@end
