//
//  AMPieChartView.h
//  pieChartView
//
//  Created by Anthony MERLE on 07/06/2014.
//  Copyright (c) 2014 Anthony Merle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMPieChartView : UIView

@property (nonatomic)  float percentage;

@property (strong, nonatomic) UIColor *externalColor;
@property (strong, nonatomic) UIColor *internalColor;

@end
