//
//  AMPieChartView.m
//  pieChartView
//
//  Created by Anthony MERLE on 07/06/2014.
//  Copyright (c) 2014 Anthony Merle. All rights reserved.
//

#import "AMPieChartView.h"

@interface AMPieChartView ()

@property (strong, nonatomic) CAShapeLayer *previousExternalPieLayer;
@property (strong, nonatomic) CAShapeLayer *previousInternalPieLayer;

@end

@implementation AMPieChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.percentage = 0.0f;
		self.internalColor = [UIColor lightGrayColor];
		self.externalColor = [UIColor grayColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andPercentage:(float)percentage
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.percentage = percentage;
		self.internalColor = [UIColor lightGrayColor];
		self.externalColor = [UIColor grayColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
		 percentage:(float)percentage
	  internalColor:(UIColor *)internalColor
	  externalColor:(UIColor *)externalColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.percentage = percentage;
		self.internalColor = internalColor;
		self.externalColor = externalColor;
    }
    return self;
}

- (void)setPercentage:(float)percentage {
	_percentage = percentage;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code

	CGPoint circleCenter = [self convertPoint:self.center fromView:self.superview];
	float circleRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2;
		
	// internal pie part
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path addArcWithCenter:circleCenter
					radius:circleRadius
				startAngle:-(M_PI/2)
				  endAngle:-(M_PI/2) + ((M_PI * 2.0) * (self.percentage/100.f))
				 clockwise:YES];

	[path addLineToPoint:circleCenter];
	[path closePath];
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [self.internalColor CGColor];
    shapeLayer.fillColor = [self.internalColor CGColor];
    shapeLayer.lineWidth = 1.;

	[self.previousInternalPieLayer removeFromSuperlayer];
	[self.layer addSublayer:shapeLayer];
	self.previousInternalPieLayer = shapeLayer;

	// external pie part
	UIBezierPath *pathExt = [UIBezierPath bezierPath];
	[pathExt addArcWithCenter:circleCenter
					   radius:circleRadius
				   startAngle:-(M_PI/2)
					 endAngle:-(M_PI/2) + (M_PI * 2.0)
					clockwise:YES];
	[pathExt closePath];
	
	CAShapeLayer *shapeLayerExt = [CAShapeLayer layer];
	shapeLayerExt.path = [pathExt CGPath];
	shapeLayerExt.strokeColor = [self.externalColor CGColor];
	shapeLayerExt.fillColor = nil;
	shapeLayerExt.lineWidth = 1.5;
	
	[self.previousExternalPieLayer removeFromSuperlayer];
	[self.layer addSublayer:shapeLayerExt];
	self.previousExternalPieLayer = shapeLayerExt;
}

@end
