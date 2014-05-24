//
//  GMMArrowView.h
//  JTSImageVC
//
//  Created by Geoff MacDonald on 2014-05-06.
//  Copyright (c) 2014 Nice Boy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMMArrowView : UIView

@property BOOL facingUp;
@property UIColor * fillColor;

-(id)initWithFrame:(CGRect)frame withDirectionUp:(BOOL)facingUp;


@end

