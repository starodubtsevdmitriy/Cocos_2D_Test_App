//
//  NextLevelScene.m
//  Cocos2DTestApp
//
//  Created by Dmitriy Starodubtsev on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NextLevelScene.h"
#import "HelloWorldLayer.h"

@implementation NextLevelScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [NextLevelLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation NextLevelLayer
@synthesize label = _label;
@synthesize controller = _controller;

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        CCMenuItem *starMenuItem = [CCMenuItemImage 
                                    itemFromNormalImage:@"next_level.png" selectedImage:@"next_level_sel.png" 
                                    target:self selector:@selector(starButtonTapped:)];
        starMenuItem.position = ccp(240, 160);
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu];   
    }	
    return self;
}

- (void)starButtonTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void)dealloc {
    [_controller release];
    [_label release];
    _label = nil;
    [super dealloc];
}

@end
