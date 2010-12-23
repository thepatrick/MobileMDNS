//
//  MDNSAPIDelegate.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDNSAPI.h"


@protocol MDNSAPIDelegate

@optional

-(void)mdnsapi:(MDNSAPI*)api didFetchDomains:(NSArray*)arrayOfDomains;

-(void)mdnsapi:(MDNSAPI*)api didFetchDomain:(NSDictionary*)domain;

@end
