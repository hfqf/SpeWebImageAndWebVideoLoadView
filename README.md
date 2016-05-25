# SpeWebImageAndWebVideoLoadView
第一版:

可直接传入图片或视频的url即可。

示例代码:

 SpeWebImageAndWebVideoLoadView *head = [[SpeWebImageAndWebVideoLoadView alloc]initWithFrame:CGRectMake(10, 10, 40, 80)];
 
head.placeholderImage = [UIImage imageNamed:@"hf.png"];

 [head setVideoUrl:[NSURL URLWithString:@"http://mabdev.oss-cn-qingdao.aliyuncs.com/note/1-1454063389277-5a65554e76bd054f99dd0386c9071c06.mp4"]];
 
 [self addSubview:head];
        
SpeWebImageAndWebVideoLoadView *head1 = [[SpeWebImageAndWebVideoLoadView alloc]initWithFrame:CGRectMake(90, 10, 50, 60)];

head1.placeholderImage = [UIImage imageNamed:@"hf.png"];

[head1 setImageForAllSDK:[NSURL URLWithString:@"http://mabdev.oss-cn-qingdao.aliyuncs.com/note/1-1442913976399-19e624939ba53714b9678e7c3fb06e74.jpeg"]];

[self addSubview:head1];

-----------------------------------------------------------------------------------------------------------------------------------------
