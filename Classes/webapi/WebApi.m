// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  ItemShelf for iPhone/iPod touch

  Copyright (c) 2008, ItemShelf Development Team. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "WebApi.h"
#import "DataModel.h"
#import "URLComponent.h"
#import "HttpClient.h"

#import "AmazonApi.h"
//#import "KakakuComApi.h"

@implementation WebApi
@synthesize delegate, serviceId;

////////////////////////////////////////////////////////////////////////
// static

/**
   Get service id from current configuration
*/
+ (int)defaultServiceId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int serviceId = [defaults integerForKey:@"ServiceId"] - 1;

    if (serviceId < 0) {  // no default settings
        serviceId = [WebApi fallbackServiceId];
    }
    return serviceId;
}

/**
   Get fallback service id from current region
*/
+ (int)fallbackServiceId
{
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    if ([country isEqualToString:@"CA"]) serviceId = AmazonCA;
    else if ([country isEqualToString:@"UK"]) serviceId = AmazonUK;
    else if ([country isEqualToString:@"FR"]) serviceId = AmazonFR;
    else if ([country isEqualToString:@"DE"]) serviceId = AmazonDE;
    else if ([country isEqualToString:@"JP"]) serviceId = AmazonJP;
    else serviceId = AmazonUS;

    return serviceId;
}

/**
   Set (save) service id settings
*/
+ (void)setDefaultServiceId:(int)serviceId
{
    ASSERT(0 <= serviceId && serviceId < MaxServiceId);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:serviceId + 1 forKey:@"ServiceId"];
}

/**
   Create WebApi instance
*/
+ (WebApi*)createWebApi:(int)serviceId
{
    WebApi *api;

    if (serviceId < 0) {
        serviceId = [self defaultServiceId];
    } else {
        switch (serviceId) {
        case AmazonUS:
        case AmazonCA:
        case AmazonUK:
        case AmazonFR:
        case AmazonDE:
        case AmazonJP:
            api = [[AmazonApi alloc] init];
            break;
#if 0
        case KakakuCom:
            api = [[KakakuComApi alloc] init];
            break;
#endif
        default:
            ASSERT(NO);
        }
    }

    [api setServiceId:serviceId];
    return api;
}

/**
   Get service id strings
*/
+ (NSArray *)getServiceIdStrings
{
    // This array must be same order with enum values.
    NSArray *ary =
        [NSArray arrayWithObjects:@"Amazon (US)",
                 @"Amazon (CA)",
                 @"Amazon (UK)",
                 @"Amazon (FR)",
                 @"Amazon (DE)",
                 @"Amazon (JP)",
#if 0
                 @"Kakaku.com (JP)",
#endif
                 nil];
    return ary;
}

////////////////////////////////////////////////////////////////////////
// WebApi

- (id)init
{
    self = [super init];
    if (self) {
        delegate = nil;
    }
    return self;
}

/**
   Set Service ID
*/
- (void)setServiceId:(int)sid
{
    // should be override
}

/**
   Execute item search
*/
- (void)itemSearch
{
    ASSERT(NO); // must be override
}

/**
   Start http request
*/
- (void)sendHttpRequest:(NSURL*)url
{
    HttpClient *httpClient = [[HttpClient alloc] init:self];
    [httpClient requestGet:uri];
    [httpClient release];
}

/**
   @name HttpClientDelegate
*/
//@{

- (void)httpClientDidFailed:(HttpClient*)client error:(NSError*)err
{
    // show error : TBD
    if (delegate) {
        [delegate webApiDidFailed:self reason:WEBAPI_ERROR_NETWORK message:nil];
    }
}

// 読み込み完了時の処理
- (void)httpClientDidFinish:(HttpClient*)client
{
    // You must override this method
#if 0
    NSString *response = [[[NSString alloc] initWithData:client.receivedData encoding:NSUTF8StringEncoding] autorelease];
    LOG(@"response = %@", response);
    //const char *utf8 = [response UTF8String];
#endif
}

//@}

@end