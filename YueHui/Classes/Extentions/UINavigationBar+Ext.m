//
//  UINavigationBar+Extra.m
//  YueHui
//
//  Created by Lei Perry on 3/14/13.
//  Copyright (c) 2013 BitRice. All rights reserved.
//

#import "UINavigationBar+Ext.h"
#import "UIColor+Ext.h"

#define kTitleLabelTag 1

@implementation UINavigationBar (Ext)

- (void)setBackgroundImage:(UIImage *)image {
    if (image == NULL)
        return;
    
    UIImageView *aTabBarBackground = [[UIImageView alloc] initWithImage:image];
    aTabBarBackground.frame = self.bounds;
//    [[self.subviews objectAtIndex:0] setHidden:YES];
//    NSLog(@"%@, %d", NSStringFromCGRect(self.frame), self.subviews.count);
//    for (int i=0; i<self.subviews.count; i++) {
//        NSLog(@"%@", [self.subviews objectAtIndex:i]);
//    }
    [self addSubview:aTabBarBackground];
//    [self sendSubviewToBack:aTabBarBackground];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.tag = kTitleLabelTag;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:19];
    label.textColor = [UIColor colorWithHex:0xc1f0ff];
    label.textAlignment = UITextAlignmentCenter;
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    [self addSubview:label];
}

- (void)setTitle:(NSString *)title {
    UILabel *label = (UILabel *)[self viewWithTag:kTitleLabelTag];
    label.text = title;
}

@end