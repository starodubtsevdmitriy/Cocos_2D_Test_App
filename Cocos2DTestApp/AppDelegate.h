//
//  AppDelegate.h
//  Cocos2DTestApp
//
//  Created by Dmitriy Starodubtsev on 03.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property int currentLevel;



@end
