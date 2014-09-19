//
//  CloudTableView.m
//  Cloudiversity
//
//  Created by Nainculte on 13/07/2014.
//  Copyright (c) 2014 Cloudiversity. All rights reserved.
//

#import "CloudTableView.h"

@implementation CloudTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id<CloudTableViewDelegate>)delegate
{
    return (id<CloudTableViewDelegate>)[super delegate];
}

- (void)setDelegate:(id<CloudTableViewDelegate>)delegate
{
    [super setDelegate:delegate];
    _flags.delegateWillReloadData = [delegate respondsToSelector:@selector(tableViewWillReloadData:)];
    _flags.delegateDidReloadData = [delegate respondsToSelector:@selector(tableViewDidReloadData:)];
}

- (void)reloadData
{
    if (_flags.delegateWillReloadData) {
        [(id<CloudTableViewDelegate>)self.delegate tableViewWillReloadData:self];
    }
    [super reloadData];
    _flags.reloading = 1;
    [self performSelector:@selector(finishReload) withObject:nil afterDelay:0.0f];
}

- (void)finishReload
{
    _flags.reloading = 0;
    if (_flags.delegateDidReloadData) {
        [(id<CloudTableViewDelegate>)self.delegate tableViewDidReloadData:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
