//
//  TestTableCell.h
//  TestController
//
//  Created by Lion User on 29/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoinViewController.h"
#import "MatchmakingClient.h"

@interface TestTableCell :UITableViewCell


{
    UIButton *Speaker;
    UILabel *PhoneName;
    int *row;

    
    MatchmakingClient *_matchmakingClient;;
    
}
@property (nonatomic,retain)IBOutlet UIButton *Speaker;
@property (nonatomic,retain)IBOutlet UILabel *PhoneName;
@property (nonatomic)int *row;


-(IBAction)SpeakerTouched:(id)sender;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tag:(NSInteger)tag;
@end
