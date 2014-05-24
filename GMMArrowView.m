//
//  GMMArrowView.m
//  JTSImageVC
//
//  Created by Geoff MacDonald on 2014-05-06.
//  Copyright (c) 2014 Nice Boy, LLC. All rights reserved.
//

#import "GMMArrowView.h"

#define kArrowPointCount 7

@interface UIBezierPath (dqd_arrowhead)

//from http://stackoverflow.com/questions/13528898/how-can-i-draw-an-arrow-using-core-graphics

+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength;

@end

@implementation UIBezierPath (dqd_arrowhead)


+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength {
    //define the arrow with the dimensions
    
    CGFloat length = hypotf(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    
    CGPoint points[kArrowPointCount];
    [self dqd_getAxisAlignedArrowPoints:points
                              forLength:length
                              tailWidth:tailWidth
                              headWidth:headWidth
                             headLength:headLength];
    
    CGAffineTransform transform = [self dqd_transformForStartPoint:startPoint
                                                          endPoint:endPoint
                                                            length:length];
    
    CGMutablePathRef cgPath = CGPathCreateMutable();
    CGPathAddLines(cgPath, &transform, points, sizeof points / sizeof *points);
    CGPathCloseSubpath(cgPath);
    
    UIBezierPath *uiPath = [UIBezierPath bezierPathWithCGPath:cgPath];
    CGPathRelease(cgPath);
    return uiPath;
}

+ (void)dqd_getAxisAlignedArrowPoints:(CGPoint[kArrowPointCount])points
                            forLength:(CGFloat)length
                            tailWidth:(CGFloat)tailWidth
                            headWidth:(CGFloat)headWidth
                           headLength:(CGFloat)headLength {
    //composes path by making the 7 points that make up an arrow
    CGFloat tailLength = length - headLength;
    points[0] = CGPointMake(0, tailWidth / 2);
    points[1] = CGPointMake(tailLength, tailWidth / 2);
    points[2] = CGPointMake(tailLength, headWidth / 2);
    points[3] = CGPointMake(length, 0);
    points[4] = CGPointMake(tailLength, -headWidth / 2);
    points[5] = CGPointMake(tailLength, -tailWidth / 2);
    points[6] = CGPointMake(0, -tailWidth / 2);
}

+ (CGAffineTransform)dqd_transformForStartPoint:(CGPoint)startPoint
                                       endPoint:(CGPoint)endPoint
                                         length:(CGFloat)length {
    //transforms the arrow to align to dimensions
    CGFloat cosine = (endPoint.x - startPoint.x) / length;
    CGFloat sine = (endPoint.y - startPoint.y) / length;
    return (CGAffineTransform){ cosine, sine, -sine, cosine, startPoint.x, startPoint.y };
}

@end

@implementation GMMArrowView

-(id)initWithFrame:(CGRect)frame withDirectionUp:(BOOL)facingUp{
    
    if(self = [super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor clearColor];
        self.facingUp = facingUp;
        
        if(facingUp)
            self.fillColor = [UIColor colorWithRed:133/255.0f green:191/255.0f blue:37/255.0f alpha:1];
        else
            self.fillColor = [UIColor colorWithRed:238/255.0f green:68/255.0f blue:68/255.0f alpha:1];
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    
    CGPoint top,bottom;
    
    //flip arrow to the right direction
    if(!_facingUp){
        bottom = CGPointMake(rect.size.width/2, rect.size.height);
        top = CGPointMake(rect.size.width/2, 0);
    } else {
        top = CGPointMake(rect.size.width/2, rect.size.height);
        bottom = CGPointMake(rect.size.width/2, 0);
    }
    
    // path from above
    UIBezierPath *aPath = [UIBezierPath dqd_bezierPathWithArrowFromPoint:top toPoint:bottom tailWidth:rect.size.height/10 headWidth:rect.size.width/2 headLength:rect.size.height/2];
    
    // Set the render colors.
    [self.fillColor setFill];
    aPath.lineWidth = rect.size.height/5;
    //paint
    [aPath fill];
}


@end
