//
//  GBSpeechSynthesizerItem.h
//  Audrey
//
//  Created by Andrew A.A. on 21/09/12.
//  Copyright (c) 2012 Andrew A.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger GBRowViewType;

enum {
	GBHeaderRow = 1001,
	GBCommonRow = 1002,
	GBUninitialized = 0
};

@interface GBSpeechSynthesizerItem : NSObject

- (id)initWithVoiceIdentifier:(NSString *)identifier;
- (id)initWithLocaleIdentifier:(NSString *)identifier;

@property (nonatomic, strong) NSString *voiceIdentifier;
@property (nonatomic, strong) NSString *localeIdentifier;

@property (nonatomic, assign, readonly) GBRowViewType rowType;
@property (nonatomic, strong, readonly) NSString *voiceDisplayName;
@property (nonatomic, strong, readonly) NSString *localeDisplayName;

- (BOOL)isEqual:(id)object;
- (BOOL)isEqualTo:(id)object;

@end




@interface NSMutableArray (GBSpeechSynthesizerItemCategory)

- (NSInteger)objectIdenticalTo:(NSString *)anObject rowType:(GBRowViewType)rowType;		//	returns the index or NSNotFound if not found

@end