//
//  GMMImageViewController.h
//  JTSImageVC
//
//  Created by Geoff MacDonald on 2014-05-06.
//  Copyright (c) 2014 Nice Boy, LLC. All rights reserved.
//

#import "JTSImageViewController.h"

typedef NS_ENUM(NSInteger, GMMVoteType) {
    GMMVoteDownVote = - 1,
    GMMVoteNoVote,
    GMMVoteUpVote
};


@protocol GMMVoteImageViewDelegate <NSObject>

/**
 Informs delegate of vote type after image has been dismissed
 
 @param imageViewer the GMMVoteImageViewController 
 @param imageVote the user's vote, GMMVoteNoVote if they dismissed without voting
 */
- (void)imageViewerDidDismiss:(JTSImageViewController *)imageViewer withVote:(GMMVoteType)imageVote;

@end

/**
 Hacking JTSImageViewController to show up and down vote arrows and to add UIDynamic's generated animations for a vote
 */
@interface GMMVoteImageViewController : JTSImageViewController <JTSImageViewControllerDismissalDelegate>

/**
 This classes set itself as the JTSImageViewControllerDismissalDelegate and uses voteResult to inform GMMVoteImageViewDelegate 
 of result when it's called
 */
@property (weak) id<GMMVoteImageViewDelegate> voteDelegate;
/**
 The users vote, set after dismissal
 */
@property GMMVoteType voteResult;
/**
 Velocity the image is moving when flicking to require a vote in that direction
 */
@property CGFloat minVerticalVelocityForVote;

@end
