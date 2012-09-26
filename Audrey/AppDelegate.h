//
//  AppDelegate.h
//  Audrey
//
//  Created by Andrew A.A. on 21/09/12.
//  Copyright (c) 2012 Andrew A.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSSpeechSynthesizerDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (assign) IBOutlet NSWindow *window;

@end


//@interface NSScroller (MyScroller)
//
//+ (CGFloat)scrollerWidth;
//+ (CGFloat)scrollerWidthForControlSize: (NSControlSize)controlSize;
//
//@end
