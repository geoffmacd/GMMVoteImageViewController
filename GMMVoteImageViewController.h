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

- (void)imageViewerDidDismiss:(JTSImageViewController *)imageViewer withVote:(GMMVoteType)vote;

@end

@interface GMMVoteImageViewController : JTSImageViewController <JTSImageViewControllerDismissalDelegate>

@property (weak) id<GMMVoteImageViewDelegate> voteDelegate;
@property GMMVoteType voteResult;

@end
