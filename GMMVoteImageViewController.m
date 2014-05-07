//
//  GMMImageViewController.m
//  JTSImageVC
//
//  Created by Geoff MacDonald on 2014-05-06.
//  Copyright (c) 2014 Nice Boy, LLC. All rights reserved.
//

#import "GMMVoteImageViewController.h"

#import "GMMArrowView.h"

@interface JTSImageViewController ()

@property (strong, nonatomic) UIView *blackBackdrop;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) BOOL scrollViewIsAnimatingAZoom;
@property (assign, nonatomic) BOOL isAnimatingAPresentationOrDismissal;
@property (assign, nonatomic) BOOL isDraggingImage;

- (void)dismissImageWithFlick:(CGPoint)velocity;
- (void)dismissingPanGestureRecognizerPanned:(UIPanGestureRecognizer *)panner;
- (void)_viewDidLoadForImageMode;
- (void)updateInterfaceWithImage:(UIImage *)image;
- (CGFloat)appropriateDensityForView:(UIView *)view;
- (void)startImageDragging:(CGPoint)panGestureLocationInView translationOffset:(UIOffset)translationOffset;
- (void)cancelCurrentImageDrag:(BOOL)animated;
- (void)updateDimmingViewForCurrentZoomScale:(BOOL)animated;

@end

@interface GMMVoteImageViewController ()

@property GMMArrowView * upArrow;
@property GMMArrowView * downArrow;
//collection of arrows displayed upon up or down vote
@property NSArray * celebratoryArrows;
@property (strong, nonatomic) UIDynamicAnimator *arrowAnimator;
@property (strong, nonatomic) UIDynamicBehavior  *arrowBehaviour;

@end

@implementation GMMVoteImageViewController

-(void)updateInterfaceWithImage:(UIImage *)image{
    
    [super updateInterfaceWithImage:image];
    
    if (image) {
        
        if(!self.upArrow){
            self.upArrow = [[GMMArrowView alloc] initWithFrame:[self.view convertRect:CGRectMake(self.view.center.x-12, 3, 25, 40) toView:self.blackBackdrop] withDirectionUp:YES];
            self.downArrow = [[GMMArrowView alloc] initWithFrame:[self.view convertRect:CGRectMake(self.view.center.x-12, self.view.bounds.size.height - 43, 25, 40) toView:self.blackBackdrop] withDirectionUp:NO];
            self.upArrow.alpha = 0;
            self.downArrow.alpha = 0;
            self.arrowAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.blackBackdrop];
        }
        
        //ok to add in arrows
        [self.blackBackdrop addSubview:self.upArrow];
        [self.blackBackdrop addSubview:self.downArrow];
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.upArrow setAlpha:1];
            [self.downArrow setAlpha:1];
        }];
    }
}

-(void)_viewDidLoadForImageMode{
    
    [super _viewDidLoadForImageMode];

    self.upArrow = [[GMMArrowView alloc] initWithFrame:[self.view convertRect:CGRectMake(self.view.center.x-12, 3, 25, 40) toView:self.blackBackdrop] withDirectionUp:YES];
    self.downArrow = [[GMMArrowView alloc] initWithFrame:[self.view convertRect:CGRectMake(self.view.center.x-12, self.view.bounds.size.height - 43, 25, 40) toView:self.blackBackdrop] withDirectionUp:NO];
    self.upArrow.alpha = 0;
    self.downArrow.alpha = 0;
    self.arrowAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.blackBackdrop];
    
    self.dismissalDelegate = self;
}

- (void)dismissingPanGestureRecognizerPanned:(UIPanGestureRecognizer *)panner {
    
    [super dismissingPanGestureRecognizerPanned:panner];
    
    if (self.scrollViewIsAnimatingAZoom || self.isAnimatingAPresentationOrDismissal) {
        return;
    }
    
    if (panner.state == UIGestureRecognizerStateChanged) {
        if (self.isDraggingImage) {
            self.arrowBehaviour.action();
        }
    }
}

- (void)updateDimmingViewForCurrentZoomScale:(BOOL)animated {
    
    [super updateDimmingViewForCurrentZoomScale:animated];
    
    BOOL isDimmed = !(self.scrollView.zoomScale > 1);
    //need to show or hide the arrows since the user cannot flick anyway
    if(isDimmed){
        
        [UIView animateWithDuration:0.2f animations:^{
            
            self.upArrow.alpha = 1;
            self.downArrow.alpha = 1;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.2f animations:^{
            
            self.upArrow.alpha = 0;
            self.downArrow.alpha = 0;
        }];
    }
}

#pragma mark - Dynamic Image Dragging

- (void)startImageDragging:(CGPoint)panGestureLocationInView translationOffset:(UIOffset)translationOffset {
    
    [super startImageDragging:panGestureLocationInView translationOffset:translationOffset];
    
    __weak GMMVoteImageViewController *weakSelf = self;
    self.arrowBehaviour = [[UIDynamicBehavior alloc] init];
    [self.arrowBehaviour setAction:^{
        
        //rotate arow according to how tilted the image is
        CGFloat rad =atan2f(weakSelf.imageView.transform.b, weakSelf.imageView.transform.a);
        if(rad > 0 )
            rad = MIN(rad, M_PI_4);
        else
            rad = MAX(rad, -M_PI_4);
        CGPoint center = CGPointMake(weakSelf.scrollView.contentSize.width/2.0f, weakSelf.scrollView.contentSize.height/2.0f);
        //scale image acc to how close to edge
        CGFloat scale = 1 - ((weakSelf.imageView.center.y - center.y) / 200);
        //minimize effect of rotation if image closer to the edges
        if(scale > 1)
            rad = rad / scale;
        else
            rad = rad * scale;
        
        //up arrow
        CGAffineTransform transform = CGAffineTransformMakeScale(1, scale);
        weakSelf.upArrow.transform = CGAffineTransformRotate(transform, -rad);
        
        
        //down arrow
        scale = 1 + ((weakSelf.imageView.center.y - center.y) / 200);
        transform = CGAffineTransformMakeScale(1, scale);
        weakSelf.downArrow.transform = CGAffineTransformRotate(transform, rad);
        
    }];
    [self.arrowAnimator addBehavior:self.arrowBehaviour];
}

- (void)cancelCurrentImageDrag:(BOOL)animated {
    
    [super cancelCurrentImageDrag:animated];
    
    [self.arrowAnimator removeAllBehaviors];
    self.upArrow.transform  = CGAffineTransformIdentity;
    self.downArrow.transform  = CGAffineTransformIdentity;
}

- (void)dismissImageWithFlick:(CGPoint)velocity {
    
    [super dismissImageWithFlick:velocity];
    
    [self.upArrow removeFromSuperview];
    [self.downArrow removeFromSuperview];
    [self.arrowAnimator removeAllBehaviors];
    
    BOOL dirUp = (velocity.y < 0 ? YES : NO);
    
    if(!self.minVerticalVelocityForVote)
        self.minVerticalVelocityForVote = 1000.0f;
    
    if(fabsf(velocity.y)> self.minVerticalVelocityForVote){
        
        //qualifies as flick
        if(!dirUp)
            self.voteResult = GMMVoteDownVote;
        else
            self.voteResult = GMMVoteUpVote;
        
        //add 10 arrows in direction of flick
        NSMutableArray * arrowArray = [NSMutableArray new];
        CGRect targetFrame = self.downArrow.frame;
        targetFrame.size = CGSizeMake(20, 30);
        BOOL dirUp = (velocity.y < 0 ? YES : NO);
        
        for(NSInteger i = 0; i < 20; i++){
            
            CGRect arrowFrame = targetFrame;
            arrowFrame.origin.x = arrowFrame.origin.x - 180 + ((float)rand() / RAND_MAX) * 360;
            arrowFrame.origin.y = arrowFrame.origin.y - ((float)rand() / RAND_MAX) * 200;
            GMMArrowView * arrow = [[GMMArrowView alloc] initWithFrame:arrowFrame withDirectionUp:dirUp];
            [self.blackBackdrop addSubview:arrow];
            [arrowArray addObject:arrow];
        }
        self.celebratoryArrows = [NSArray arrayWithArray:arrowArray];
        UIPushBehavior * arrowPush = [[UIPushBehavior alloc] initWithItems:self.celebratoryArrows mode:UIPushBehaviorModeContinuous];
        [arrowPush setPushDirection:CGVectorMake(0, velocity.y*0.2)];
        UIDynamicItemBehavior *modifier = [[UIDynamicItemBehavior alloc] initWithItems:arrowArray];
        [modifier setAngularResistance:15];
        [modifier setDensity:[self appropriateDensityForView:[arrowArray firstObject]]];
        [self.arrowAnimator addBehavior:modifier];
        [self.arrowAnimator addBehavior:arrowPush];
    }
}

#pragma mark - JTSImageViewControllerDismissalDelegate

-(void)imageViewerDidDismiss:(JTSImageViewController *)imageViewer{
    
    if([self.voteDelegate conformsToProtocol:@protocol(GMMVoteImageViewDelegate)])
        [self.voteDelegate imageViewerDidDismiss:self withVote:self.voteResult];
}

@end
