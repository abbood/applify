//
//  PlayListTableCell.h
//  TestController
//
//  Created by Lion User on 12/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListTableCell : UITableViewCell
{
    UIButton *Add;
    UIView *Remove;
    UILabel *SongName;
    UILabel *Artistname;
    
}

@property (nonatomic,retain)IBOutlet UIButton *Add;
@property (nonatomic,retain)IBOutlet UIView *Remove;
@property (nonatomic,retain)IBOutlet UILabel *SongName;
@property (nonatomic,retain)IBOutlet UILabel *Artistname;
@property (nonatomic)int *row;
-(IBAction)AddTouched:(id)sender;
-(IBAction)RemoveTouched:(id)sender;
@end
