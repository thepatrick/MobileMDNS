//
//  DomainListViewController.h
//  MobileAutoTorrents
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDNSAPIDelegate.h"

@class DomainViewController;
@class MDNSAPI;

@interface DomainListViewController : UITableViewController {

	DomainViewController *domainViewController;
	NSArray *domains;
	MDNSAPI *api;
}

@property (nonatomic, retain) IBOutlet DomainViewController *domainViewController;
@property (nonatomic, retain) IBOutlet MDNSAPI *api;
@property (nonatomic, retain) NSArray *domains;

@end
