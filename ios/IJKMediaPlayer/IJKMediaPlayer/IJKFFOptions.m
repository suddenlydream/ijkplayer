/*
 * IJKFFOptions.m
 *
 * Copyright (c) 2013-2015 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import "IJKFFOptions.h"
#include "ijkplayer/ios/ijkplayer_ios.h"

@implementation IJKFFOptions {
    NSMutableDictionary *_optionCategories;

    NSMutableDictionary *_playerOptions;
    NSMutableDictionary *_formatOptions;
    NSMutableDictionary *_codecOptions;
    NSMutableDictionary *_swsOptions;
}

+ (IJKFFOptions *)optionsByDefault
{
    IJKFFOptions *options = [[IJKFFOptions alloc] init];

    [options setMaxFps:30];
    [options setFrameDrop:0];
    [options setVideoPictureSize:3];
    [options setVideoToolboxMaxFrameWidth:960];

    [options setReconnect:1];
    [options setTimeout:30 * 1000 * 1000];
    [options setUserAgent:@"ijkplayer"];

    [options setSkipLoopFilter:IJK_AVDISCARD_ALL];
    [options setSkipFrame:IJK_AVDISCARD_NONREF];

    return options;
}

- (id)init
{
    self = [super init];
    if (self) {
        _playerOptions      = [[NSMutableDictionary alloc] init];
        _formatOptions      = [[NSMutableDictionary alloc] init];
        _codecOptions       = [[NSMutableDictionary alloc] init];
        _swsOptions         = [[NSMutableDictionary alloc] init];

        _optionCategories   = [[NSMutableDictionary alloc] init];
        _optionCategories[@(IJKMP_OPT_CATEGORY_PLAYER)] = _playerOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_FORMAT)] = _formatOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_CODEC)]  = _codecOptions;
        _optionCategories[@(IJKMP_OPT_CATEGORY_SWS)]    = _swsOptions;
    }
    return self;
}

- (void)applyTo:(IjkMediaPlayer *)mediaPlayer
{
    [_optionCategories enumerateKeysAndObjectsUsingBlock:^(id categoryKey, id categoryDict, BOOL *stopOuter) {
        [categoryDict enumerateKeysAndObjectsUsingBlock:^(id optKey, id optValue, BOOL *stop) {
            if ([optValue isKindOfClass:[NSNumber class]]) {
                ijkmp_set_option_int(mediaPlayer,
                                     [categoryKey integerValue],
                                     [optKey UTF8String],
                                     [optValue longLongValue]);
            } else if ([optValue isKindOfClass:[NSString class]]) {
                ijkmp_set_option(mediaPlayer,
                                 [categoryKey integerValue],
                                 [optKey UTF8String],
                                 [optValue UTF8String]);
            }
        }];
    }];
}

- (void)setOptionValue:(NSString *)value
                forKey:(NSString *)key
            ofCategory:(IJKFFOptionCategory)category
{
    if (!key)
        return;

    NSMutableDictionary *options = [_optionCategories objectForKey:@(category)];
    if (options) {
        if (value) {
            [options setObject:value forKey:key];
        } else {
            [options removeObjectForKey:key];
        }
    }
}

- (void)setOptionIntValue:(int64_t)value
                   forKey:(NSString *)key
               ofCategory:(IJKFFOptionCategory)category
{
    if (!key)
        return;

    NSMutableDictionary *options = [_optionCategories objectForKey:@(category)];
    if (options) {
        [options setObject:@(value) forKey:key];
    }
}


#pragma mark Common Helper

-(void)setFormatOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategoryFormat];
}

-(void)setCodecOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategoryCodec];
}

-(void)setSwsOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategorySws];
}

-(void)setPlayerOptionValue:(NSString *)value forKey:(NSString *)key
{
    [self setOptionValue:value forKey:key ofCategory:kIJKFFOptionCategoryPlayer];
}

-(void)setFormatOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategoryFormat];
}

-(void)setCodecOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategoryCodec];
}

-(void)setSwsOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategorySws];
}

-(void)setPlayerOptionIntValue:(int64_t)value forKey:(NSString *)key
{
    [self setOptionIntValue:value forKey:key ofCategory:kIJKFFOptionCategoryPlayer];
}


#pragma mark Player options

-(void)setMaxFps:(int)value
{
    [self setPlayerOptionIntValue:value forKey:@"max-fps"];
}

-(void)setFrameDrop:(int)value
{
    [self setPlayerOptionIntValue:value forKey:@"framedrop"];
}

-(void)setVideoPictureSize:(int)value
{
    [self setPlayerOptionIntValue:value forKey:@"video-pictq-size"];
}

-(void)setVideoToolboxEnabled:(BOOL)value
{
    [self setPlayerOptionIntValue:(value ? 1 : 0) forKey:@"videotoolbox"];
}

-(void)setVideoToolboxMaxFrameWidth:(int)value
{
    [self setPlayerOptionIntValue:value forKey:@"videotoolbox-max-frame-width"];
}


#pragma mark Format options

-(void)setReconnect:(int)value
{
    [self setFormatOptionIntValue:value forKey:@"reconnect"];
}

-(void)setTimeout:(int64_t)value
{
    [self setFormatOptionIntValue:value forKey:@"timeout"];
}

-(void)setUserAgent:(NSString *)value
{
    [self setFormatOptionValue:value forKey:@"user-agent"];
}


#pragma mark Codec options

-(void)setSkipLoopFilter:(IJKAVDiscard)value
{
    [self setCodecOptionIntValue:value forKey:@"skip_loop_filter"];
}

-(void)setSkipFrame:(IJKAVDiscard)value
{
    [self setCodecOptionIntValue:value forKey:@"skip_frame"];
}

@end
