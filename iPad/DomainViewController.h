//
//  DomainViewController.h
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDNSAPIDelegate.h"
#import "MDNSModalDelegate.h"
#import "MBProgressHUD.h"

@interface DomainViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MDNSAPIDelegate, UINavigationControllerDelegate, MDNSModalDelegate, MBProgressHUDDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
	MDNSAPI *api;
	
    id detailItem;
	
	NSDictionary *domain;
	NSArray *records;
    
    NSArray *sectionTitles;
    NSMutableDictionary *recordsByGrouping;
	
	UITableView *tableView;
	
	MBProgressHUD *HUD;
	
	BOOL loading;
}

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) MDNSAPI *api;

@property (nonatomic, retain) NSDictionary *domain;
@property (nonatomic, retain) NSArray *records;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *label;

@property (nonatomic, retain) NSDictionary *recordsByGrouping;

-(IBAction)refreshDomain:(id)sender;
-(IBAction)publishDomain:(id)sender;

-(void)reloadData;

@end
