//
//  SpeImageAndVideoLoadView.h
//  MotherBabyGood
//
//  Created by points on 16/5/25.
//  Copyright © 2016年 points. All rights reserved.
//

@protocol SpeWebImageAndWebVideoLoadViewDelegate <NSObject>

@required

- (void)onSelectSpeWebImageAndWebVideoLoadView:(NSInteger)index;

@end
#import "EGOImageView.h"

@interface SpeWebImageAndWebVideoLoadView : EGOImageView
{
    UIButton *m_palyBtn;
}

@property (nonatomic,assign)BOOL      m_isVideo;
@property (nonatomic,strong)NSURL    *m_videoUrl;
@property (nonatomic,strong)NSURL    *m_videoLocalPath;
@property (nonatomic,weak)id<SpeWebImageAndWebVideoLoadViewDelegate>m_delegate;

- (void)setVideoUrl:(NSURL *)url;

- (void)setVideoUrl:(NSURL *)url withDefaultImage:(UIImage *)img;
@end
