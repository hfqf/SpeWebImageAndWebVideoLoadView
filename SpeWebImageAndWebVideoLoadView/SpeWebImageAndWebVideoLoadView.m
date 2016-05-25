//
//  SpeImageAndVideoLoadView.m
//  MotherBabyGood
//
//  Created by points on 16/5/25.
//  Copyright © 2016年 points. All rights reserved.
//

#import "SpeWebImageAndWebVideoLoadView.h"
#import <AVFoundation/AVFoundation.h>
@implementation SpeWebImageAndWebVideoLoadView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        m_palyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [m_palyBtn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [m_palyBtn setImage:[UIImage imageNamed:@"ic_video_play"] forState:UIControlStateNormal];
        [m_palyBtn setImageEdgeInsets:UIEdgeInsetsMake((frame.size.height-30)/2, (frame.size.width-30)/2, (frame.size.height-30)/2, (frame.size.width-30)/2)];
        [m_palyBtn addTarget:self action:@selector(playVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:m_palyBtn];
    }
    return self;
}

- (void)playVideoBtnClicked
{
    if(self.m_delegate && [self.m_delegate respondsToSelector:@selector(onSelectSpeWebImageAndWebVideoLoadView:)])
    {
        [self.m_delegate onSelectSpeWebImageAndWebVideoLoadView:self.tag];
    }
}

- (void)setVideoUrl:(NSURL *)url
{
    self.m_isVideo = YES;
    if(self.m_videoUrl) {
        [[EGOImageLoader sharedImageLoader] removeObserver:self forURL:self.m_videoUrl];
        self.m_videoUrl = nil;
    }
    
    if(!url) {
        self.m_videoUrl = nil;
        return;
    } else {
        self.m_videoUrl = url;
    }
    
    [[EGOImageLoader sharedImageLoader] removeObserver:self];
    NSString* path = [[EGOImageLoader sharedImageLoader] videoPathForURL:url shouldLoadWithObserver:self];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        self.m_videoLocalPath = [NSURL URLWithString:path];
        UIImage *snapshot = [self thumbnailImageForVideo:[NSURL fileURLWithPath:path] atTime:0];
        self.image = snapshot;
        if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
            [self.delegate imageViewLoadedImage:self];
        }
    } else {
        self.image = self.placeholderImage;
    }
}


- (void)setVideoUrl:(NSURL *)url withDefaultImage:(UIImage *)img
{
    self.placeholderImage = img;
    self.m_isVideo = YES;
    
    if(self.m_videoUrl) {
        [[EGOImageLoader sharedImageLoader] removeObserver:self forURL:self.m_videoUrl];
        self.m_videoUrl = nil;
    }
    
    if(!url) {
        self.m_videoUrl = nil;
        return;
    } else {
        self.m_videoUrl = url;
    }
    
    [[EGOImageLoader sharedImageLoader] removeObserver:self];
    NSString* path = [[EGOImageLoader sharedImageLoader] videoPathForURL:url shouldLoadWithObserver:self];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        self.m_videoLocalPath = [NSURL URLWithString:path];
        UIImage *snapshot = [self thumbnailImageForVideo:[NSURL fileURLWithPath:path] atTime:0];
        self.image = snapshot;
        if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
            [self.delegate imageViewLoadedImage:self];
        }
    } else {
        self.image = self.placeholderImage;
    }
}


- (void)imageLoaderDidLoad:(NSNotification*)notification {
    
    if(self.m_isVideo)
    {
        if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.m_videoUrl]) return;
        
        UIImage* anImage        = [[notification userInfo] objectForKey:@"image"];
        NSString* path          = [[notification userInfo] objectForKey:@"videoPath"];
        
        UIImage *snapshot       = [self thumbnailImageForVideo:[NSURL fileURLWithPath:path] atTime:0];
        self.image              =  snapshot;
        self.m_videoLocalPath   = [NSURL URLWithString:path];
        [self setNeedsDisplay];
        
        if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
            [self.delegate imageViewLoadedImage:self];
        }
    }
    else
    {
        if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
        
        UIImage* anImage = [[notification userInfo] objectForKey:@"image"];
        self.image = anImage;
        [self setNeedsDisplay];
        
        if([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
            [self.delegate imageViewLoadedImage:self];
        }
    }


 
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
    if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
    
    if([self.delegate respondsToSelector:@selector(imageViewFailedToLoadImage:error:)]) {
        [self.delegate imageViewFailedToLoadImage:self error:[[notification userInfo] objectForKey:@"error"]];
    }
}


/**
 *  @brief 根据本地视频路径返回一个某帧的截图
 *
 *  @param videoURL 本地视频路径
 *  @param time     哪帧
 *
 *  @return 某帧的截图
 */
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:opts];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    
    //CMTimeValue  value = asset.duration.value;//总帧数
    CMTimeScale  timeScale =   asset.duration.timescale; //timescale为  fps
    NSError *error = nil;
    CMTime actualTime;
    
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(time, timeScale) actualTime:&actualTime error:&error];
    if (!error)
        NSLog(@"thumbnailImageGenerationError %@", error);
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}

@end
