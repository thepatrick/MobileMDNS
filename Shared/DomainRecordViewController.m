//
//  DomainRecordViewController.m
//  MobileMDNS
//
//  Created by Patrick Quinn-Graham on 29/08/10.
//  Copyright (c) 2010 Patrick Quinn-Graham. All rights reserved.
//

#import "DomainRecordViewController.h"
#import "TextFieldCell.h"


@implementation DomainRecordViewController

@synthesize record, delegate;

+drvcForRecord:(NSDictionary*)record {
    DomainRecordViewController *drvc = [[[DomainRecordViewController alloc] initWithNibName:@"DomainRecordViewController" bundle:nil] autorelease];
    drvc.record = record;
    return drvc;
}

- (void)setRecord:(NSDictionary*)newRecord {
	if(record == newRecord) {
		return;
	}
	[record release];
	record = nil;
	if(newRecord) {
		record = [newRecord retain];
		self.title = [NSString stringWithFormat:@"%@ Record", [newRecord objectForKey:@"resource_type"]];
	} else {
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    //self.title = @"Domain record!";
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		UIBarButtonItem *cancelMe = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissMe:)];
		self.navigationItem.leftBarButtonItem = cancelMe;
		[cancelMe release];
		
		UIBarButtonItem *saveMe = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveMe:)];
		self.navigationItem.rightBarButtonItem = saveMe;
		[saveMe release];
	} else {
	}
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)saveMe:(id)sender {
	NSLog(@"Did done hit save with record: %@", record);
}

- (void)save:(id)sender {
	
}


- (void)dismissMe:(id)sender {
	[delegate dismissModal:self];
	//[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSString *type = [record objectForKey:@"resource_type"];
	if([type isEqualToString:@"MX"]) {
		return 3;
	}
	if([type isEqualToString:@"SRV"]) {
		return 5;
	}
	return 2;
}

-(UITableViewCell *)textfieldCellForTitle:(NSString*)title andValue:(NSString*)value andChangedSelector:(SEL)action andKeyboardType:(UIKeyboardType)keyboard
{
	
    static NSString *CellIdentifier = @"CellTextField";
    TextFieldCell *cell = (TextFieldCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.textColor = [UIColor darkGrayColor];
	cell.textLabel.font = [UIFont systemFontOfSize:16];
	cell.textLabel.text = title;
	
	[cell.valueTextField addTarget:self action:action forControlEvents:UIControlEventEditingDidEndOnExit];
	[cell.valueTextField addTarget:self action:action forControlEvents:UIControlEventEditingDidEnd];
	
	cell.valueTextField.text = value;
	cell.valueTextField.keyboardType = keyboard;
	cell.valueTextField.delegate = self;
	
	return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch(indexPath.row) {
		case 0: // name
			return [self textfieldCellForTitle:@"Name" andValue:[record objectForKey:@"name"] andChangedSelector:@selector(didModifyName:) andKeyboardType:UIKeyboardTypeURL];
		case 1: // ip/host
			return [self textfieldCellForTitle:@"IP/Host" andValue:[record objectForKey:@"target"] andChangedSelector:@selector(didModifyTarget:) andKeyboardType:UIKeyboardTypeURL];
			break;
		case 2: // priority
			return [self textfieldCellForTitle:@"Priority" andValue:[[record objectForKey:@"priority"] stringValue] andChangedSelector:@selector(didModifyTarget:) andKeyboardType:UIKeyboardTypeNumberPad];
			break;
		case 3: // weight
			return [self textfieldCellForTitle:@"Weight" andValue:[[record objectForKey:@"weight"] stringValue] andChangedSelector:@selector(didModifyTarget:) andKeyboardType:UIKeyboardTypeNumberPad];
			break;
		case 4: // port
			return [self textfieldCellForTitle:@"Port" andValue:[[record objectForKey:@"port"] stringValue] andChangedSelector:@selector(didModifyTarget:) andKeyboardType:UIKeyboardTypeNumberPad];
			break;
	}
    return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TextFieldCell *cell = (TextFieldCell*)[tableView cellForRowAtIndexPath:indexPath];
	[cell.valueTextField becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark TextField callbacks

-(void)didModifyName:(UITextField*)sender {
	[record setValue:sender.text forKey:@"name"];
}
-(void)didModifyTarget:(UITextField*)sender {
	[record setValue:sender.text forKey:@"target"];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [record release];
    [super dealloc];
}


@end

