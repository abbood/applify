//
//  PlayListTableCell.m
//  TestController
//
//  Created by Lion User on 12/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayListTableCell.h"
#import "MusicTableViewController.h"

@implementation PlayListTableCell
@synthesize Add;
@synthesize Remove;
@synthesize SongName;
@synthesize row;
-(IBAction)AddTouched:(id)sender
{
        if ([sender isSelected])
        {
            [sender setImage:[UIImage imageNamed:@"speakers states2.png"] forState:UIControlStateNormal];
            [sender setSelected:NO];
            self.SongName.textColor   = [UIColor darkGrayColor];
    
    
               }
        else {
            [sender setImage:[UIImage imageNamed:@"speakers states3.png"]forState:UIControlStateSelected];
            [sender
             setSelected:YES];
            UIImage *myGradient = [UIImage imageNamed:@"Gradient.png"];
            self.SongName.textColor   = [UIColor colorWithPatternImage:myGradient];
            MusicTableViewController *table=[[MusicTableViewController alloc]init ];
          //  table.cellarray =[[NSMutableArray alloc]init];
    
            [table.cellarray replaceObjectAtIndex:self.row withObject:@"c"] ;
        }
}

-(IBAction)RemoveTouched:(id)sender
{
    
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

@end
