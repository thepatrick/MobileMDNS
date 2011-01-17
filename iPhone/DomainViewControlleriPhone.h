//
//  DomainViewControlleriPhone.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 17/01/11.
//  Copyright 2011 Sharkey Media. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MDNSAPIDelegate.h"
#import "MDNSModalDelegate.h"
#import "MBProgressHUD.h"

@interface DomainViewControlleriPhone : UITableViewController<MDNSModalDelegate, MBProgressHUDDelegate> {
@private
    
    MDNSAPI *api;
	
    id detailItem;
	
	NSDictionary *domain;
	NSArray *records;
    
    NSArray *sectionTitles;
    NSMutableDictionary *recordsByGrouping;
	
	MBProgressHUD *HUD;
	
	BOOL loading;

    
}

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) MDNSAPI *api;

@property (nonatomic, retain) NSDictionary *domain;
@property (nonatomic, retain) NSArray *records;

@property (nonatomic, retain) NSDictionary *recordsByGrouping;

-(IBAction)refreshDomain:(id)sender;
-(IBAction)publishDomain:(id)sender;

-(void)reloadData;

@end
