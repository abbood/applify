//
//  CustomSearchBar.m
//  Applify
//
//  Created by Lion User on 9/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomSearchBar.h"

@implementation CustomSearchBar



- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image=[UIImage imageNamed:@"searchbarBG.png"];

    //self.frame=CGRectMake(140, 53, image.size.width, image.size.height);

    self.backgroundImage  =image;
}
@end
