//
//  GBSpeechSynthesizerItem.m
//  Audrey
//
//  Created by Andrew A.A. on 21/09/12.
//  Copyright (c) 2012 Andrew A.A. All rights reserved.
//

#import "GBSpeechSynthesizerItem.h"

NSLocale *gCurrentLocale;
NSMutableDictionary *gLocaleInformation;		//	key - locale identifier; value - locale display name

@interface GBSpeechSynthesizerItem ()

@end

@implementation GBSpeechSynthesizerItem

@synthesize voiceIdentifier  = _voiceIdentifier;
@synthesize localeIdentifier = _localeIdentifier;

@synthesize voiceDisplayName  = _voiceDisplayName;
@synthesize localeDisplayName = _localeDisplayName;

@synthesize rowType = _rowType;


+ (void)initialize
{
	gCurrentLocale = [NSLocale currentLocale];
	gLocaleInformation = [[NSMutableDictionary alloc] initWithCapacity:3];
}

- (id)initWithLocaleIdentifier:(NSString *)identifier
{
	if ((self = [super init])) {
		self.localeIdentifier = identifier;
		_rowType = GBHeaderRow;
	}

	return self;
}

- (id)initWithVoiceIdentifier:(NSString *)identifier
{
	if ((self = [super init])) {
		self.voiceIdentifier = identifier;
		_rowType = GBCommonRow;
	}
	
	return self;
}

- (void)dealloc
{
	[_voiceIdentifier release];
	[_localeIdentifier release];
	[_voiceDisplayName release];
	[_localeDisplayName release];

	[super dealloc];
}

- (NSString *)description
{
	if (_rowType == GBCommonRow)
		return self.voiceDisplayName;
	else
		return self.localeDisplayName;
}

- (void)setLocaleIdentifier:(NSString *)localeIdentifier
{
	_localeIdentifier = [localeIdentifier retain];

	if (!(_localeDisplayName = [gLocaleInformation valueForKey:_localeIdentifier])) {
		@autoreleasepool {
			_localeDisplayName = [gCurrentLocale displayNameForKey:NSLocaleIdentifier value:_localeIdentifier];
			[gLocaleInformation setValue:_localeDisplayName forKey:_localeIdentifier];
		}
	}
}

- (void)setVoiceIdentifier:(NSString *)voiceIdentifier
{
	@autoreleasepool {
		NSDictionary *voiceAttributes = [NSSpeechSynthesizer attributesForVoice:voiceIdentifier];

		_voiceIdentifier = [voiceIdentifier retain];
		_voiceDisplayName = [[voiceAttributes valueForKey:NSVoiceName] retain];
	}
}

- (BOOL)isEqual:(id)object
{
	NSLog(@"%s - %@ : %@", __PRETTY_FUNCTION__, self, object);
	return [object isEqualToString:_voiceDisplayName];
}

- (BOOL)isEqualTo:(id)object
{
	NSLog(@"%s - %@ : %@", __PRETTY_FUNCTION__, self, object);
	return [object isEqualToString:_voiceDisplayName];
}

@end



@implementation NSMutableArray (GBSpeechSynthesizerItemCategory)

- (NSInteger)objectIdenticalTo:(NSString *)anObject rowType:(GBRowViewType)rowType
{
	for (int index = 0; index < self.count; ++index) {
		GBSpeechSynthesizerItem *anItem = [self objectAtIndex:index];

		if (anItem.rowType == rowType) {
			if (rowType == GBHeaderRow) {
				if ([anItem.localeIdentifier isEqualToString:anObject])
					return index;
			}
			else {
				if ([anItem.voiceIdentifier isEqualToString:anObject])
					return index;
			}
		}
	}

	return NSNotFound;
}

@end






