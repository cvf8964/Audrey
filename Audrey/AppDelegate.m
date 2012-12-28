//
//  AppDelegate.m
//  Audrey
//
//  Created by Andrew A.A. on 21/09/12.
//  Copyright (c) 2012 Andrew A.A. All rights reserved.
//

#import "AppDelegate.h"
#import "GBSpeechSynthesizerItem.h"

NSString *kPrefDefaultVoice;

@interface AppDelegate ()

@property (nonatomic, retain) NSMutableArray *availableVoices;
@property (nonatomic, retain) NSSpeechSynthesizer *speechSynthesizer;

@property (nonatomic, unsafe_unretained) IBOutlet NSTableView *voicesTable;
@property (nonatomic, unsafe_unretained) IBOutlet NSButton *speakButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSButton *stopButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *textView;

- (IBAction)speakButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;

//- (BOOL)isHeaderRow

@end

@implementation AppDelegate

@synthesize availableVoices = _availableVoices;
@synthesize speechSynthesizer = _speechSynthesizer;

@synthesize voicesTable, speakButton, stopButton, textView;

+ (void)initialize
{
	kPrefDefaultVoice = [[NSString alloc] initWithFormat:@"Default Voice"];

	NSDictionary *userDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:[NSSpeechSynthesizer defaultVoice], kPrefDefaultVoice, nil];

	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

- (id)init
{
	if ((self = [super init])) {
		_speechSynthesizer = [[NSSpeechSynthesizer alloc] init];
		_speechSynthesizer.delegate = self;
	}

	return self;
}

- (void)dealloc
{
	[_speechSynthesizer release];
	[_availableVoices release];

	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.stopButton setEnabled:NO];
	[self.speakButton setEnabled:YES];
	[self.voicesTable setEnabled:YES];

	NSString *voice = [[NSUserDefaults standardUserDefaults] stringForKey:kPrefDefaultVoice];
	NSUInteger voiceIndex = [self.availableVoices objectIdenticalTo:voice rowType:GBCommonRow];
	
	if (voiceIndex == NSNotFound)
		voiceIndex = [self.availableVoices objectIdenticalTo:[NSSpeechSynthesizer defaultVoice] rowType:GBCommonRow];

	NSIndexSet *voiceIndexSet = [[NSIndexSet alloc] initWithIndex:voiceIndex];
	NSScrollView *scrollView = self.voicesTable.enclosingScrollView;

	[scrollView.verticalScroller setControlSize:NSSmallControlSize];

	[self.voicesTable selectRowIndexes:voiceIndexSet byExtendingSelection:NO];
	[self.voicesTable scrollRowToVisible:voiceIndex];

	[voiceIndexSet release];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return !self.window.isVisible;
}

- (NSMutableArray *)availableVoices
{
	if (!_availableVoices) {
		_availableVoices = [[NSMutableArray alloc] initWithCapacity:10];
		NSArray *voices = [NSSpeechSynthesizer availableVoices];

		NSMutableDictionary *voicesDictionary = [[NSMutableDictionary alloc] init];

		for (NSString *voiceIdentifier in voices)
		{
			@autoreleasepool {
				NSDictionary *voiceAttributes = [NSSpeechSynthesizer attributesForVoice:voiceIdentifier];
				NSString *voiceLocaleIdentifier = [voiceAttributes valueForKey:NSVoiceLocaleIdentifier];
				NSMutableArray *voiceList;

				if ((voiceList = [voicesDictionary objectForKey:voiceLocaleIdentifier]))
					[voiceList addObject:voiceIdentifier];
				else {
					voiceList = [[NSMutableArray alloc] initWithObjects:voiceIdentifier, nil];
					[voicesDictionary setValue:voiceList forKey:voiceLocaleIdentifier];
					[voiceList release];
				}
			}
		}

		NSEnumerator *keyEnum = [voicesDictionary keyEnumerator];
		NSEnumerator *objectEnum = [voicesDictionary objectEnumerator];
		NSArray *anArray;

		while (anArray = [objectEnum nextObject]) {
			GBSpeechSynthesizerItem *headerRowItem = [[GBSpeechSynthesizerItem alloc] initWithLocaleIdentifier:[keyEnum nextObject]];
			[_availableVoices addObject:headerRowItem];
			[headerRowItem release];
			
			for (NSString *voiceIdentifier in anArray) {
				GBSpeechSynthesizerItem *aVoice = [[GBSpeechSynthesizerItem alloc] initWithVoiceIdentifier:voiceIdentifier];
				[_availableVoices addObject:aVoice];
				[aVoice release];
			}
		}

		[voicesDictionary release];
	}

	return _availableVoices;
}


#pragma mark
#pragma mark SpeechSynthesizer Actions

- (void)speakButtonPressed:(id)sender
{
	if ([self.textView.string isEqualToString:@""])
		return;

	[self.speechSynthesizer startSpeakingString:self.textView.string];

	[self.speakButton setEnabled:NO];
	[self.stopButton setEnabled:YES];
	[self.voicesTable setEnabled:NO];
}

- (void)stopButtonPressed:(id)sender
{
	[self.speechSynthesizer stopSpeaking];

	[self.speakButton setEnabled:YES];
	[self.stopButton setEnabled:NO];
	[self.voicesTable setEnabled:YES];
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking
{
	[self.speakButton setEnabled:YES];
	[self.stopButton setEnabled:NO];
	[self.voicesTable setEnabled:YES];
}


#pragma mark
#pragma mark TableView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return self.availableVoices.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[self.availableVoices objectAtIndex:row] description];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSUInteger voiceIndex = self.voicesTable.selectedRow;
	GBSpeechSynthesizerItem *selectedVoice = [self.availableVoices objectAtIndex:voiceIndex];

	[self.speechSynthesizer setVoice:selectedVoice.voiceIdentifier];
	[[NSUserDefaults standardUserDefaults] setValue:selectedVoice.voiceIdentifier forKey:kPrefDefaultVoice];

	[self.window setTitle:selectedVoice.voiceDisplayName];
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
	GBSpeechSynthesizerItem *anObject = [self.availableVoices objectAtIndex:row];
	return anObject.rowType == GBHeaderRow;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	GBSpeechSynthesizerItem *anObject = [self.availableVoices objectAtIndex:row];
	return anObject.rowType == GBCommonRow;
}


@end


//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
//
//@implementation NSScroller (MyScroller)
//
//+ (CGFloat)scrollerWidth
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//    return 10;
//}
//
//+ (CGFloat)scrollerWidthForControlSize: (NSControlSize)controlSize
//{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
//    return 10;
//}
//
//@end
//
//#pragma clang diagnostic pop



