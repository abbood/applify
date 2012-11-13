//
//  PlayListTableCell.m
//  TestController
//
//  Created by Lion User on 12/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayListTableCell.h"
#import "Simple_PlayerViewController.h"
#import "MPMediaItemCollection-Utils.h"
@implementation PlayListTableCell
@synthesize Add;
@synthesize Remove;
@synthesize SongName;
@synthesize row;
-(IBAction)AddTouched:(id)sender
{
    Simple_PlayerViewController *table=[[Simple_PlayerViewController alloc]init ];
    
    if ([sender isSelected])
    {
        [table.player setNowPlayingItem:nil];
        [sender setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        self.SongName.textColor   = [UIColor darkGrayColor];
        [table playOrPauseAtindex:row];
        
        
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"speakers states3.png"]forState:UIControlStateSelected];
        [sender setSelected:YES];
        UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
        self.SongName.textColor   = [UIColor colorWithPatternImage:myGradient];
        
        //call play at index
        
        [table playOrPauseAtindex:row];
    }
}

-(IBAction)RemoveTouched:(id)sender
{
    Simple_PlayerViewController *table=[[Simple_PlayerViewController alloc]init];
    [table removeTrack:row];
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)highlightRow
{
    [Add setImage:[UIImage imageNamed:@"speakers states3.png"]forState:UIControlStateSelected];
    [Add setSelected:YES];
    UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
    self.SongName.textColor = [UIColor colorWithPatternImage:myGradient];
    Simple_PlayerViewController *table=[[Simple_PlayerViewController alloc]init ];
    [table.cellarray replaceObjectAtIndex:self.row withObject:@"c"] ;
    
    
    
}


@end
