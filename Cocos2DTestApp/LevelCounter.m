//
//  LevelCounter.m
//  Cocos2DTestApp
//
//  Created by Dmitriy Starodubtsev on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelCounter.h"

@implementation LevelCounter

@synthesize levelCount = _levelCount;

- (void) nextLevel {
    _levelCount++;
}

@end
