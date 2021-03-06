//
//  CouponViewController.m
//  YueHui
//
//  Created by Lei Perry on 3/16/13.
//  Copyright (c) 2013 BitRice. All rights reserved.
//

#import "CouponCollectionViewController.h"
#import "UINavigationBar+Ext.h"
#import "UIColor+Ext.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@interface CouponCollectionViewController ()
- (void)handleLeftPan:(UIPanGestureRecognizer *)recognizer ;
- (void)handleRightPan:(UIPanGestureRecognizer *)recognizer ;
- (void)handleDownPan:(UIPanGestureRecognizer *)recognizer ;

@end


@implementation CouponCollectionViewController

UIPanGestureRecognizer *pan;
- (void)loadView {
    [super loadView];
    
    // init vars    
    backZ=0;
    frontZ=1;
    stackCount=6;
    positionCount = 6;
    visbleCardCount = 3;
    imageHeight = 292;
    
    isExpanded = NO;
    isAnimating = NO;
    height = 98;

    // app background
    self.view.backgroundColor = [UIColor colorWithHex:0xedeae1];
    UIImage *appBg = [[UIImage imageNamed:@"app-bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImageView *appBgView = [[UIImageView alloc] initWithImage:appBg];
    appBgView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), appBg.size.height);
    [self.view addSubview:appBgView];
        
    //    UIImageView *coupons = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coupon-collection-bg"]];
    //    coupons.center = CGPointMake(160, 170);
    //    [self.view addSubview:coupons];
    
    
    
    
    
    
    

    imageViews = [[NSMutableArray alloc] initWithCapacity:stackCount];
    
    CGRect r = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - (85));
    scrollView=[[UIScrollView alloc] initWithFrame:r];
    [self.view addSubview:scrollView];
    scrollView.scrollEnabled = YES;
    scrollView.contentSize = CGSizeMake(r.size.width, imageHeight+(stackCount-1)*height);
    scrollView.delegate = self;

    for (int i=0; i<stackCount; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat: @"store_b%d",i]];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.center =  CGPointMake(160,200);
        [scrollView addSubview:imageView];
        
        imageView.layer.masksToBounds       = NO;
        imageView.layer.shadowRadius        = 2.0;
        imageView.layer.shadowColor         = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset        = CGSizeMake(.5, .5);
        imageView.layer.shadowOpacity       = .7f;
        imageView.layer.zPosition = backZ--;
        imageView.layer.borderWidth        = 5;
        imageView.layer.borderColor        = [[UIColor whiteColor] CGColor];
        imageView.layer.shouldRasterize     =YES;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageView.bounds];
        imageView.layer.shadowPath = path.CGPath;
        imageView.tag = i;
        
        CGFloat radians = M_PI * 8+(i*2) / 360.0;
        if(arc4random()%10 >6)
            radians*=-1.0f;
        CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             imageView.transform = transform;
                             imageView.center =  CGPointMake(160,imageView.center.y-i*5);
                         }];
        
        //
        [imageViews addObject:imageView];
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] ;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
    topImageView= (UIImageView*)[imageViews objectAtIndex:0];
    origanPoint = ((UIImageView*)[imageViews objectAtIndex:0]).center;

    [self resetGestureOrderAndTag];
        
    //
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] ;
    //[oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [scrollView addGestureRecognizer:pan];
    
    
    UIImage *handleImage = [UIImage imageNamed:[NSString stringWithFormat: @"handle"]];
    handleImageView = [[UIImageView alloc]initWithImage:handleImage];
    handleImageView.center =  CGPointMake(160,0);
    handleImageView.alpha=0;
    [scrollView addSubview:handleImageView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         handleImageView.center =  CGPointMake(160,20);
                         handleImageView.alpha = 1;
                     }];
    
    
    UITapGestureRecognizer *handleTapG =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapHandle:)];
    handleImageView.userInteractionEnabled = YES;
    [handleImageView addGestureRecognizer:handleTapG];
    handleImageView.layer.zPosition=999999;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTitle:@"我的优惠券"];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint velocity2 = [recognizer velocityInView:self.view];
    //    NSLog(@"pan velocity2: %f,%f", velocity2.x, velocity2.y);
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pad began");
        
        if(velocity2.y<0&& fabs(velocity2.y)>fabs(velocity2.x*2)){
            NSLog(@"to up");
            panDirction = 0;
        }
        else if(velocity2.y>0&& fabs(velocity2.y)>fabs(velocity2.x*2)){
            NSLog(@"to down");
            panDirction = 2;
        }
        else if(velocity2.x<0 ){
            NSLog(@"to left");
            panDirction = 3;
        }
        else {//(velocity2.x>0&& fabs(velocity2.x)>fabs(velocity2.y*2))
            NSLog(@"to right");
            panDirction = 1;
        }
        startGestureVelocity = velocity2;
    }
    
    //    NSLog(@"pan location: %f,%f", translation.x, translation.y);
    
    if(panDirction==3){
        [self handleLeftPan:recognizer];
    }
    if(panDirction==1){
        [self handleRightPan:recognizer];
    }
    if(panDirction==2 || panDirction==0){
        [self handleDownPan:recognizer];
    }
}


//UIImageView* flyingImageView;
- (void)handleLeftPan:(UIPanGestureRecognizer *)recognizer
{
    if(isExpanded) return;
    if(isAnimating) return;
    
    CGPoint translation = [recognizer translationInView:self.view];
    NSLog(@"transloation.x: %f",translation.x);
    NSLog(@"tag:%d",topImageView.tag);
    
    topImageView.center = CGPointMake(topImageView.center.x + translation.x,
                                      topImageView.center.y + 0);
    NSLog(@"x:%f",    topImageView.center.x);
    
    if (topImageView.center.x>origanPoint.x) {
        topImageView.center=CGPointMake(origanPoint.x, topImageView.center.y);
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    //
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        //
        //        CGFloat magnitude = sqrtf((velocity.x * velocity.x));// + (velocity.y * velocity.y));
        //
        //        CGFloat slideMult = magnitude / 200;
        //
        //        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        //float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        
        float s = 300/fabs(velocity.x);
        
        CGPoint finalPoint = origanPoint;
        if(s<0.7 && velocity.x<0)
            finalPoint = CGPointMake(-200,
                                     topImageView.center.y);
        
        //finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        //finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        NSLog(@"s: %f, vel x: %f",s,velocity.x);
        //        if(s>0.7 && velocity.x>=0)
        //            finalPoint = origanPoint;
        //if (slideMult>1) { // fast engough
        //            finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor),
        //                                             recognizer.view.center.y + (velocity.y * slideFactor));
        
        //            finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        //            finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        //finalPoint.x = -200;
        // }
        
        isAnimating=YES;
        [UIView animateWithDuration:(s>0.7)?0.7:s
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             topImageView.center = finalPoint;
                         }
                         completion:^(BOOL b){
                             if(finalPoint.x < 0){
                                 [UIView animateWithDuration:0.2
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      UIImageView* lastImageView = [imageViews objectAtIndex:imageViews.count-1];
                                                      topImageView.center = CGPointMake(lastImageView.center.x, lastImageView.center.y-5);
                                                      topImageView.layer.zPosition=backZ--;
                                                  }
                                                  completion:^(BOOL b){
                                                     UIImageView* flyingImageView=topImageView;
                                                     [imageViews removeObjectAtIndex:0];
                                                     topImageView=[imageViews objectAtIndex:0];
//                                                     flyingImageView.hidden=NO;
//                                                     flyingImageView.layer.zPosition = backZ--;
                                                     UIImageView* lastImageView = [imageViews objectAtIndex:imageViews.count-1];
                                                     flyingImageView.center=CGPointMake(lastImageView.center.x,
                                                                                        lastImageView.center.y - 5);
                                                     [imageViews addObject:flyingImageView];
                                                     NSLog(@"lastImageView: %f",lastImageView.center.x);
                                                     NSLog(@"flyingImageView: %f",flyingImageView.center.x);

                                                     
                                                     for (int i=0; i<stackCount; i++) {
                                                         UIImageView* m = (UIImageView*)[imageViews objectAtIndex:i];
                                                         
                                                         [UIView animateWithDuration:0.3
                                                                               delay:0
                                                                             options:UIViewAnimationOptionCurveEaseOut
                                                                          animations:^{
                                                                              m.center = CGPointMake(m.center.x, m.center.y+5);
                                                                          }
                                                                          completion:nil];
                                                         
                                 }
                                 [self resetGestureOrderAndTag];
                                                  }];
                             }
                             isAnimating=NO;
                         }];
    }
}

UIImageView* flyingInImageView;
- (void)handleRightPan:(UIPanGestureRecognizer *)recognizer {
    if(isExpanded) return;
    if(isAnimating) return;
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIImageView* lastImageView = [imageViews objectAtIndex:imageViews.count-1];
        flyingInImageView = lastImageView;

        flyingInImageView.center = CGPointMake(-100, origanPoint.y);
//        flyingInImageView.hidden=NO;
        flyingInImageView.layer.zPosition = frontZ++;

    }
    
    NSLog(@"%f, %f",flyingInImageView.center.x,flyingInImageView.center.y);
    CGPoint translation = [recognizer translationInView:self.view];
    NSLog(@"%f",translation.x);
    
    
    flyingInImageView.center = CGPointMake(flyingInImageView.center.x + translation.x,
                                           flyingInImageView.center.y + 0);
    if (flyingInImageView.center.x>origanPoint.x) {
        flyingInImageView.center=CGPointMake(origanPoint.x, flyingInImageView.center.y);
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    NSLog(@"%f",flyingInImageView.center.x);
    //
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        float s = 300/fabs(velocity.x);
        
        CGPoint finalPoint = CGPointMake(-200,
                                         flyingInImageView.center.y);
        
        NSLog(@"s: %f",s);
        if(s<0.7 && velocity.x>0)
            finalPoint = origanPoint;
        
        isAnimating=YES;
        [UIView animateWithDuration:(s>0.7)?0.7:s
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             flyingInImageView.center = finalPoint;
                         }
                         completion:^(BOOL b){
                             if(finalPoint.x > 0){
                                 [imageViews insertObject:flyingInImageView atIndex:0];
                                 [imageViews removeObjectAtIndex:imageViews.count-1];
                                 
                                 for (int i=1; i<stackCount; i++) {
                                     UIImageView* m = (UIImageView*)[imageViews objectAtIndex:i];
                                     
                                     [UIView animateWithDuration:0.3
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseOut
                                                      animations:^{
                                                          m.center = CGPointMake(m.center.x, m.center.y-5);
                                                      }
                                                      completion:nil];
                                     
                                 }
                                 topImageView=(UIImageView*)[imageViews objectAtIndex:0];
                             }
                             else {
                                 flyingInImageView.layer.zPosition=backZ;
                                 
                                 UIImageView* v = (UIImageView*)[imageViews objectAtIndex:imageViews.count-2];
                                 flyingInImageView.center =CGPointMake(origanPoint.x, v.center.y-5);
                             }
                             
                             isAnimating=NO;
                             [self resetGestureOrderAndTag];
                         }];
        
    }
}

- (void)handleDownPan:(UIPanGestureRecognizer *)recognizer {
    if(isAnimating) return;

    if(handleImageView.alpha>0){
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [handleImageView setAlpha:0];
                     }
                     completion:nil];
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    
//    if(isExpandedToBottom && translation.y>0) {
//        pan.enabled = NO;
//        return;
//    }

    
    //    flyingInImageView.center = CGPointMake(flyingInImageView.center.x + translation.x,
    //                                           flyingInImageView.center.y + 0);

    UIImageView* first = (UIImageView*)[imageViews objectAtIndex:0];
    UIImageView* last = (UIImageView*)[imageViews objectAtIndex:imageViews.count-1];
    NSLog(@"%f, %f",last.center.y,first.center.y);
    
    int y = first.center.y+translation.y;
    if(y > origanPoint.y )
    {
        first.center= CGPointMake(first.center.x, y);
        for (int i=1; i<stackCount; i++) {
            UIImageView* m = (UIImageView*)[imageViews objectAtIndex:i];
            m.center = CGPointMake(m.center.x, m.center.y+translation.y*(stackCount-i)/stackCount);
        }
    }
    if(isExpanded){
        UIImageView* m = (UIImageView*)[imageViews objectAtIndex:0];
        [scrollView scrollRectToVisible:CGRectMake(0, m.center.y-imageHeight/2-20, 10, 10) animated:NO];
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        float s = 300/fabs(velocity.y);
        CGPoint finalPoint = CGPointMake(-200,
                                         flyingInImageView.center.y);
        
        NSLog(@"s: %f",s);
        if(s<0.7 && velocity.x>0)
            finalPoint = origanPoint;
        
        isAnimating=YES;
        [UIView animateWithDuration:(s>0.7)?0.7:s
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             //                             flyingInImageView.center = finalPoint;
                             if(s>0.7 || velocity.y<0){
                                 for (int i=0; i<stackCount; i++) {
                                     UIImageView* m = (UIImageView*)[imageViews objectAtIndex:i];
                                     m.center = CGPointMake(m.center.x,
                                                            origanPoint.y-i*5);
                                     [handleImageView setAlpha:1];
                                 }
                                 [scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
                             }
                             else{// to expanded
                                 for (int i=0; i<stackCount; i++) {
                                     UIImageView* m = (UIImageView*)[imageViews objectAtIndex:i];
                                     m.center = CGPointMake(m.center.x,
                                                            imageHeight/2+stackCount*height*(stackCount-(i+1))/stackCount);
                                     NSLog(@"m.y:%f",m.center.y);
                                 }
                             }
                         }
                         completion:^(BOOL b){
                             if(s>0.7 || velocity.y<0){
                                 isExpanded = NO;
                             }
                             else{
                                [self setExpandedToTrue];
                             }
                             isAnimating=NO;
                             [self resetGestureOrderAndTag];
                         }
         ];
    }
}


- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:[self view]];
    NSLog(@"tap - start location: %f,%f", point.x, point.y);
    NSLog(@"tag: %d", recognizer.view.tag);
    if(isExpanded){
        int clickedTag = recognizer.view.tag;
        int topTag = topImageView.tag;
        
        NSMutableArray* imageViewsTmp = [[NSMutableArray alloc] initWithCapacity:stackCount];
        
        // reorder the imageViews array
        for (int i=clickedTag; i<stackCount; i++) {
            NSLog(@"i:%d", i);
            UIImageView* view = [imageViews objectAtIndex:i];
            [imageViewsTmp addObject:view];
        }
        
        NSLog(@"topTag:%d", topTag);
        NSMutableArray* belowViews = [[NSMutableArray alloc] initWithCapacity:stackCount];
        for (int i=topTag; i<clickedTag; i++) {
            NSLog(@"i2:%d", i);
            UIImageView* view = [imageViews objectAtIndex:i];
            [imageViewsTmp addObject:view];
            [belowViews addObject:view];
        }
        imageViews= imageViewsTmp;
        
        NSLog(@"images count: %d",imageViews.count);
        topImageView = (UIImageView*)[imageViews objectAtIndex:0];
        
        [scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
        pan.enabled = YES;
        [UIView animateWithDuration:.2f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             for (int i=0; i<belowViews.count; i++) {
                                 UIImageView* view = [belowViews objectAtIndex:i];
                                 view.center = CGPointMake(-200, origanPoint.y);
                             }
                         }
                         completion:^(BOOL b){
                             for (int i=0; i<belowViews.count; i++) {
                                 UIImageView* view = [belowViews objectAtIndex:i];
                                 view.layer.zPosition=backZ--;
                             }
                             [self resetGestureOrderAndTag];
                             [UIView animateWithDuration:.2f
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  for (int i=0; i<stackCount; i++) {
                                                      UIImageView* view = [imageViews objectAtIndex:i];
                                                      view.center = CGPointMake(origanPoint.x, origanPoint.y-i*5);
                                                  }
                                                  [handleImageView setAlpha:1];
                                              }
                                              completion:^(BOOL b){
                                                  isExpanded=NO;
                                              }
                              ];

                         }];
    }
}

- (void)handleTapHandle:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"tap handle.");
    isAnimating=YES;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //                             flyingInImageView.center = finalPoint;
                         for (int i=0; i<stackCount; i++) {
                             UIImageView* m = (UIImageView*)[imageViews objectAtIndex:i];
                             m.center = CGPointMake(m.center.x,
                                                    imageHeight/2+stackCount*height*(stackCount-(i+1))/stackCount);
                             NSLog(@"m.y:%f",m.center.y);
                         }
                         [handleImageView setAlpha:0];
                     }
                     completion:^(BOOL b){
                         [self setExpandedToTrue];
                         isAnimating=NO;
                         [self resetGestureOrderAndTag];
                     }

     ];

}

//BOOL isExpandedToBottom = NO;
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView;
{
    //    NSLog(@" scrollViewDidScroll");
NSLog(@"ContentOffset  x is  %f,yis %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    if(scrollView.contentOffset.y >= 407){
        pan.enabled = YES;
//        isExpandedToBottom=YES;
    }
}

-(void)setExpandedToTrue{
    isExpanded=YES;
    pan.enabled = NO;
}

-(void)resetGestureOrderAndTag {
    for (int i=stackCount-1; i>=0;i--) {
        [scrollView bringSubviewToFront:[imageViews objectAtIndex:(topImageView.tag+i)%stackCount]];
        NSLog(@"-");
    }
    [scrollView bringSubviewToFront:handleImageView];
    for (int i=0; i<stackCount; i++) {
        UIImageView* view = [imageViews objectAtIndex:i];
        view.tag = i;
    }
}

@end


/*
 
 */
@interface CardPosition: NSObject{
    
}
@property(nonatomic)CGPoint center;
@property BOOL visible;
@property int zLayer;
@end

@implementation CardPosition
- (id) init
{
	if((self = [super init])) {
        self.visible=NO;
        self.zLayer = 0;
	}
	
	return self;
}

@end


//
@interface Card: NSObject{
    
}
@property(nonatomic)UIImageView* imageView;
@property CardPosition* position;
@end

@implementation Card
- (id) init
{
	if((self = [super init])) {
        self.imageView=nil;
        self.position = nil;
	}
	
	return self;
}

@end
