    //
//  DomainViewController.m
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 10-06-19.
//  Copyright 2010 Sharkey Media. All rights reserved.
//

#import "DomainViewController.h"
#import "DomainRecordViewController.h"
#import "MDNSAPI.h"

@interface DomainViewController()

- (void)configureDomainCell:(UITableViewCell*)cell forRow:(NSInteger)row;
- (void)configureRecordCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;

- (NSInteger)recordCountOfType:(NSString*)recordType;
- (void)sortRecords;
@end

@implementation DomainViewController

@synthesize detailItem, tableView, toolbar,popoverController, api, domain, records, label, recordsByGrouping;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    sectionTitles = [[NSArray arrayWithObjects:@"Domain", @"A", @"AAAA", @"CNAME", @"MX", @"NS", @"SRV", @"TXT", nil] retain];
    
	self.api = [MDNSAPI api];
	self.api.delegate = self;
}



- (void)viewDidUnload {
    [super viewDidUnload];
	self.popoverController = nil;
    [sectionTitles release];
    sectionTitles = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
		NSLog(@"Did get detailItem %@", detailItem);
		self.label.title = [detailItem objectForKey:@"fqdn"];
 		self.domain = nil;
		self.records = nil;
		[self reloadData];
   }
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }   
}

- (void)reloadData {
	loading = YES;
	if(!HUD) {
		HUD = [[MBProgressHUD alloc] initWithView:self.view];
		HUD.labelText = @"Loading...";
		HUD.delegate = self;
		[self.view addSubview:HUD];
		[HUD show:YES];
	}
	
	[api fetchDomain:[detailItem objectForKey:@"key"]];
	[self.tableView reloadData];	
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = @"Domains";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	[popoverController release];
	[toolbar release];
	[detailItem release];
	[records release];
	[domain release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table view datasource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionTitles objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return loading || (domain == nil) ? 0 : [sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return loading ? 0 : (section == 0 ? 2 : [self recordCountOfType:[sectionTitles objectAtIndex:section]]);
}

- (NSInteger)recordCountOfType:(NSString*)recordType {
    NSArray *thisTypeRecords = [recordsByGrouping objectForKey:recordType];
    return thisTypeRecords ? [thisTypeRecords count] : 0;
}

- (void)configureDomainCell:(UITableViewCell*)cell forRow:(NSInteger)row {
	switch(row) {
		case 0:
			cell.textLabel.text = @"Version";
			cell.detailTextLabel.text = [[domain objectForKey:@"version"] stringValue];
			break;
		case 1:
			cell.textLabel.text = @"Servers";
			cell.detailTextLabel.text = @"s1.dns.m.ac.nz, s2.dns.m.ac.nz, s3.dns.m.ac.nz";
			break;
	}
}

- (void)configureRecordCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath {
	NSDictionary *record = [[recordsByGrouping objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	cell.textLabel.text = [record objectForKey:@"name"];
	cell.detailTextLabel.text = [record objectForKey:@"target"];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifierDomain = @"DomainCell";
	static NSString *CellIdentifierRecord = @"RecordCell";
	NSString *CellIdentifier = (indexPath.section == 0 ? CellIdentifierDomain : CellIdentifierRecord);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	switch(indexPath.section) {
		case 0:
			[self configureDomainCell:cell forRow:indexPath.row];
			break;
		default:
			[self configureRecordCell:cell forIndexPath:indexPath];
			break;
	}
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *record = [[self.recordsByGrouping objectForKey:[sectionTitles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    DomainRecordViewController *drvc = [DomainRecordViewController drvcForRecord:[[record mutableCopy] autorelease]];
	
	drvc.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:drvc];
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navController animated:YES];
}

- (void)dismissModal:(id)sender {
	[self reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark MDNSAPI Delegate methods

-(void)mdnsapi:(MDNSAPI*)api didFetchDomain:(NSDictionary*)apiDomain {
	NSLog(@"Got domain! %@", apiDomain);
	if([[[apiDomain objectForKey:@"domain"] objectForKey:@"id"] isEqualToString:[detailItem objectForKey:@"key"]]) {
		self.domain = [apiDomain objectForKey:@"domain"];
		self.records = [apiDomain objectForKey:@"records"];
		loading = NO;
        self.recordsByGrouping = [NSMutableDictionary dictionaryWithCapacity:[sectionTitles count]];
        [self sortRecords];
		[self.tableView reloadData];
		[HUD hide:YES];
	}
}

-(void)sortRecords {
    for(NSDictionary *record in records) {
        NSString *resType = [record objectForKey:@"resource_type"];
        NSMutableArray *resArray = [self.recordsByGrouping objectForKey:resType];
        if(!resArray) {
            resArray = [NSMutableArray arrayWithCapacity:[records count]];
            [self.recordsByGrouping setValue:resArray forKey:resType];
        }
        [resArray addObject:record];
    }
}

#pragma mark -
#pragma mark UI Actions

-(IBAction)refreshDomain:(id)sender {

}

-(IBAction)publishDomain:(id)sender {
	
}

#pragma mmark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}

@end
