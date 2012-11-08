//
//  GameDelegate.h
//  Snap
//
//  Created by Abdullah Bakhach on 11/8/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@class Game;

@protocol GameDelegate <NSObject>

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason;
- (void)gameWaitingForServerReady:(Game *)game;
- (void)gameWaitingForClientsReady:(Game *)game;
- (void)gameDidBegin:(Game *)game;

- (void)serverBroadcastDidBegin:(Game *)game;
- (void)clientReceptionDidBegin:(Game *)game;

@end



