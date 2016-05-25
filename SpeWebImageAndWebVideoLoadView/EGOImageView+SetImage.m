//
//  EGOImageView+SetImage.m
//  xxt_xj
//
//  Created by Points on 14-4-25.
//  Copyright (c) 2014年 Points. All rights reserved.
//

#import "EGOImageView+SetImage.h"

@implementation EGOImageView(publicSetImage)

- (void)dealloc
{
    if(self.m_isAddedObserver)
    {
        [self removeObserver:self forKeyPath:@"image"];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.m_isAddedObserver = NO;
        self.m_arrDefalutSize = [NSMutableArray array];
    }
    return self;
}

/**
 * @brief 直接动态加载图片
 * @param url  图片的网络地址
 **/
- (void)setImageForAllSDK:(NSURL *)url
{
    self.placeholderImage = KEY_DEFAULT_CONTENT_IAMGE;
    [self setImageURL:url];
}

/**
 * @brief 动态加载图片并设定好默认图片
 * @param url  图片的网络地址
 * @param img  默认图片
 **/
- (void)setImageForAllSDK:(NSURL *)url withDefaultImage:(UIImage *)img
{
    self.placeholderImage = img;
    [self setImageURL:url];
}


/**
 * @brief 根据剪切类型动态加载图片并设定好默认图片
 * @param url  图片的网络地址
 * @param img  默认图片
 * @param type type为yes是保持原图比例，在给定的范围内居中显示；no是保持图片比例,占满原始显示区域
 **/
- (void)setImageForAllSDK:(NSURL *)url withDefaultImage:(UIImage *)img  WithAdjustType:(BOOL)type
{
    
    [self insertDefaultImageSize:img.size];
    self.cropType = type;
    
    //防止同一个ImageView连续set了多次url,导致观察者过多而发生崩溃
    if(self.m_isAddedObserver)
    {
        [self removeObserver:self forKeyPath:@"image"];
    }

    [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.m_isAddedObserver = YES;
    [self setImageForAllSDK:url withDefaultImage:img];
}

//保存默认图片的尺寸
- (void)insertDefaultImageSize:(CGSize)defaultSize
{
    NSDictionary *defaultSizedic = CFBridgingRelease(CGSizeCreateDictionaryRepresentation(defaultSize));
    for(NSDictionary *savedSize in self.m_arrDefalutSize)
    {
        if( (NSInteger)defaultSize.height  == [savedSize[@"Height"]integerValue] &&
           (NSInteger)defaultSize.width   == [savedSize[@"Width"]integerValue])
        {
            return;//如果已有相同的宽高记录就退出
        }
    }
    [self.m_arrDefalutSize addObject:defaultSizedic];
}

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:@"image"])
    {
        UIImage * newImage = [change objectForKey:@"new"];
        if([newImage isKindOfClass:[NSNull class]])
        {
            return;
        }
        
        
        CGSize originalSize = newImage.size;
        if([self chenckReturnForDefaultImg:originalSize])
        {
            return;
        }
        if(self.cropType)
        {
            EGOImageView * imageView = (EGOImageView *)object;
            [imageView removeObserver:self forKeyPath:@"image"];
            CGSize currentSize =  [self imageConstrainedToSize:imageView.bounds.size withImage:newImage];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x+(self.bounds.size.width-currentSize.width)/2, imageView.frame.origin.y, currentSize.width, currentSize.height)];
        }
        else
        {
            //返回的图片宽高都小于给定的范围
            if (originalSize.height <= self.bounds.size.height && originalSize.width <= self.bounds.size.width)
            {
                EGOImageView * imageView = (EGOImageView *)object;
                [imageView removeObserver:self forKeyPath:@"image"];
                [imageView setFrame:CGRectMake(imageView.frame.origin.x+(self.bounds.size.width-originalSize.width)/2, imageView.frame.origin.y+(self.bounds.size.height-originalSize.height)/2, originalSize.width, originalSize.height)];
            }
            //获取的图片的高度大于默认高度,宽度小于默认宽度
            else if (originalSize.height > self.bounds.size.height && originalSize.width <= self.bounds.size.width)
            {
                EGOImageView * imageView = (EGOImageView *)object;
                CGFloat rate = self.bounds.size.width/self.bounds.size.height;
                NSInteger width = originalSize.width;
                NSInteger high = originalSize.width/rate;
                
                CGRect cutRect = CGRectMake((self.bounds.size.width-originalSize.width)/2,(self.bounds.size.height-high)/2, width,high);
                CGImageRef cr = CGImageCreateWithImageInRect([newImage CGImage], cutRect);
                UIImage *cropped = [UIImage imageWithCGImage:cr];
                CGImageRelease(cr);
                newImage = cropped;
                
                [imageView removeObserver:self forKeyPath:@"image"];
                imageView.image = newImage;
            }
            //获取的图片的高度小于默认高度,宽度大于默认宽度
            else if (originalSize.height <= self.bounds.size.height && originalSize.width > self.bounds.size.width)
            {
                
                EGOImageView * imageView = (EGOImageView *)object;
                CGFloat rate = self.bounds.size.width/self.bounds.size.height;
                NSInteger width = originalSize.width;
                NSInteger high = originalSize.width/rate;
                CGRect cutRect = CGRectMake((self.bounds.size.width-originalSize.width)/2,(self.bounds.size.height-originalSize.height)/2,width,high);
                
                CGImageRef cr = CGImageCreateWithImageInRect([newImage CGImage], cutRect);
                UIImage *cropped = [UIImage imageWithCGImage:cr];
                CGImageRelease(cr);
                newImage = cropped;
                
                [imageView removeObserver:self forKeyPath:@"image"];
                imageView.image = newImage;
                
                
            }
            //返回的图片宽高都大于给定的范围
            else
            {
                EGOImageView * imageView = (EGOImageView *)object;
                CGFloat rate = self.bounds.size.width/self.bounds.size.height;
                NSInteger width = originalSize.width;
                NSInteger high = originalSize.width/rate;
                
                CGRect cutRect;
                if(originalSize.height < high)
                {
                    cutRect = CGRectMake((originalSize.width-originalSize.height*rate)/2,0,originalSize.height*rate,originalSize.height);
                }
                else
                {
                    cutRect = CGRectMake((originalSize.width-width)/2,(originalSize.height-high)/2,width,high);
                }
                CGImageRef cr = CGImageCreateWithImageInRect([newImage CGImage], cutRect);
                UIImage *cropped = [UIImage imageWithCGImage:cr];
                CGImageRelease(cr);
                newImage = cropped;
                
                [imageView removeObserver:self forKeyPath:@"image"];
                imageView.image = newImage;
            }
        }
        self.m_isAddedObserver = NO;
    }
    else
    {
        
    }
}



//根据给定显示的最大区域和UIImage得到剪切后的size
- (CGSize)imageConstrainedToSize:(CGSize)maxSize withImage:(UIImage *)image;
{
    CGSize size = image.size;
    if (size.height <= maxSize.height && size.width <= maxSize.width)
    {
        return size;
    }
    
    CGSize fitSize = size;
    CGFloat rate = size.width/size.height;
    
    if (fitSize.height > maxSize.height)
    {
        fitSize.height = maxSize.height;
        fitSize.width = fitSize.height*rate;
    }
    
    if (fitSize.width > maxSize.width)
    {
        fitSize.width = maxSize.width;
        fitSize.height = fitSize.width/rate;
    }
    
    return fitSize;
}

//检查此次的kvo回调是不是由于默认图片导致的，如果是就return
- (BOOL)chenckReturnForDefaultImg:(CGSize)currentSize
{
    for(NSDictionary *savedSize in self.m_arrDefalutSize)
    {
        if( (NSInteger)currentSize.height  == [savedSize[@"Height"]integerValue] &&
           (NSInteger)currentSize.width  == [savedSize[@"Width"]integerValue])
        {
            return YES;//如果已有相同的宽高记录就退出
        }
        
        //@2X
        if( (NSInteger)currentSize.height  == 2*[savedSize[@"Height"]integerValue] &&
           (NSInteger)currentSize.width  == 2*[savedSize[@"Width"]integerValue])
        {
            return YES;//如果已有相同的宽高记录就退出
        }
        
        //@3X
        if( (NSInteger)currentSize.height  == 3*[savedSize[@"Height"]integerValue] &&
           (NSInteger)currentSize.width  == 3*[savedSize[@"Width"]integerValue])
        {
            return YES;//如果已有相同的宽高记录就退出
        }
    }
    return NO;
}



@end
