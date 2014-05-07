//
//  GMMArrowView.m
//  JTSImageVC
//
//  Created by Geoff MacDonald on 2014-05-06.
//  Copyright (c) 2014 Nice Boy, LLC. All rights reserved.
//

#import "GMMArrowView.h"

#define kArrowPointCount 7

@implementation UIBezierPath (dqd_arrowhead)


+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength {
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
            self.fillColor = [self colorWithHexString:@"85bf25"];
        else
            self.fillColor = [self colorWithHexString:@"ee4444"];
    }
    return self;
}
                            
-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
    
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
}
                              
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGPoint top,bottom;
    
    if(!_facingUp){
        bottom = CGPointMake(rect.size.width/2, rect.size.height);
        top = CGPointMake(rect.size.width/2, 0);
    } else {
        top = CGPointMake(rect.size.width/2, rect.size.height);
        bottom = CGPointMake(rect.size.width/2, 0);
    }
    
    // Drawing code
    UIBezierPath *aPath = [UIBezierPath dqd_bezierPathWithArrowFromPoint:top toPoint:bottom tailWidth:rect.size.height/10 headWidth:rect.size.width/2 headLength:rect.size.height/2];
    
    // Set the render colors.
    [self.fillColor setFill];
    
    // Adjust the drawing options as needed.
    aPath.lineWidth = rect.size.height/5;
    
    // Fill the path before stroking it so that the fill
    // color does not obscure the stroked line.
    [aPath fill];
}


@end
