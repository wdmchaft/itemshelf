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

#import "KeywordViewController2.h"
#import "AppDelegate.h"
#import "SearchController.h"

@implementation KeywordViewController2

@synthesize selectedShelf, initialText;

+ (KeywordViewController2 *)keywordViewController:(NSString*)title
{
    KeywordViewController2 *vc = [[[KeywordViewController2 alloc]
                                     initWithNibName:@"KeywordView2"
                                     bundle:nil] autorelease];
    vc.title = title;

    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    webApiFactory = [[WebApiFactory alloc] init];

    textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 13, 190, 22)];
    //textField.backgroundColor = [UIColor grayColor];
    textField.font = [UIFont systemFontOfSize: 14.0];
    textField.textColor = [UIColor blackColor];
    textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    textField.placeholder = self.title;
    textField.clearButtonMode = UITextFieldViewModeAlways;

    if (initialText != nil) {
        textField.text = initialText;
    }
	
    [self _setupCategories];
    
    // key type
    keyType = 0;
    keyTypes = [[NSArray alloc] initWithObjects:@"Title", @"Keyword", nil];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                 target:self
                                                 action:@selector(cancelAction:)] autorelease];
}

- (void)_setupCategories
{
    [searchIndices release];
    WebApi *api = [webApiFactory createWebApi];

    searchIndices = [api categoryStrings];
    [searchIndices retain];

    searchSelectedIndex = [api defaultCategoryIndex];

    [api release];
}

- (void)dealloc {
    [textField release];
    [searchIndices release];
    [keyTypes release];
    [initialText release];
    [webApiFactory release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [textField becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)doneAction:(id)sender
{
    // 検索
    if (textField.text.length < 2) {
        [Common showAlertDialog:@"Error" message:@"Title is too short"];
        return;
    }

    [textField resignFirstResponder];
	
    SearchController *sc = [SearchController newController];
    sc.delegate = self;
    sc.viewController = self;
    sc.selectedShelf = selectedShelf;

    WebApi *api = [webApiFactory createWebApi];
    NSString *searchIndex = [searchIndices objectAtIndex:searchSelectedIndex];
    switch (keyType) {
        case 0:
            // Title search
            [sc search:api withTitle:textField.text withIndex:searchIndex];
            break;
        case 1:
            // Keyword search
            [sc search:api key:textField.text keyType:SEARCH_KEY_KEYWORD index:searchIndex];
            break;
    }
        
    [api release];
}

- (void)searchControllerFinish:(SearchController*)controller result:(BOOL)result
{
    if (result) {
        //textField.text = nil;
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/////


// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *text;
    
    switch (indexPath.row) {
    case 0: // text view
        cell = [self containerCellWithTitle:@"Keyword" view:textField];
        break;

    case 1: // category (index)
        text = [searchIndices objectAtIndex:searchSelectedIndex];
        cell = [self containerCellWithTitle:@"Category" text:text];
        break;

    case 2:
        text = [keyTypes objectAtIndex:keyType];
        cell = [self containerCellWithTitle:@"Type" text:text];
        break;

    case 3: // service id
        text = [webApiFactory serviceIdString];
        cell = [self containerCellWithTitle:@"Service" text:text];
        break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GenSelectListViewController *vc = nil;
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    switch (indexPath.row) {
    case 1: // category (index)
        vc = [GenSelectListViewController
                 genSelectListViewController:self
                 array:searchIndices
                 title:NSLocalizedString(@"Category", @"")];
        vc.selectedIndex = searchSelectedIndex;
        vc.identifier = 0;
        break;

    case 2: // key type
        vc = [GenSelectListViewController
                 genSelectListViewController:self
                 array:keyTypes
                 title:NSLocalizedString(@"Search type", @"")];
        vc.selectedIndex = keyType;
        vc.identifier = 1;
        break;
            
    case 3: // serviceId
        vc = [GenSelectListViewController
                 genSelectListViewController:self
                 array:[webApiFactory serviceIdStrings]
                 title:NSLocalizedString(@"Select locale", @"")];
        vc.selectedIndex = webApiFactory.serviceId;
        vc.identifier = 2;
        break;
    }

    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}
       

- (void)genSelectListViewChanged:(GenSelectListViewController*)vc
{
    switch (vc.identifier) {
    case 0: // serchIndex
        searchSelectedIndex = vc.selectedIndex;
        break;

    case 1: // key type
        keyType = vc.selectedIndex;
        break;
            
    case 2: // serviceId
        webApiFactory.serviceId = vc.selectedIndex;
        [webApiFactory saveDefaults];
        [self _setupCategories];
        break;
    }
    [tableView reloadData];
}

- (UITableViewCell *)containerCellWithTitle:(NSString*)title view:(UIView *)view
{
    KeywordViewCell *cell = [KeywordViewCell allocCell:title tableView:tableView identifier:title];
    [cell attachView:view];
    return cell;
}

- (UITableViewCell *)containerCellWithTitle:(NSString*)title text:(NSString *)text
{
    KeywordViewCell *cell = [KeywordViewCell allocCell:title tableView:tableView identifier:title];

    UILabel *value;
    value = [[[UILabel alloc] initWithFrame:CGRectMake(110, 6, 190, 32)] autorelease];
    value.text = NSLocalizedString(text, @"");
    value.font = [UIFont systemFontOfSize: 14.0];
    value.textColor = [UIColor blackColor];
    value.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell attachView:value];    
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end

////
// KeywordViewCell

@implementation KeywordViewCell

+ (KeywordViewCell *)allocCell:(NSString *)title tableView:(UITableView*)tableView identifier:(NSString *)identifier
{
    KeywordViewCell *cell = (KeywordViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[KeywordViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
    }
    
    UILabel *tlabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 6, 90, 32)] autorelease];
    tlabel.text = NSLocalizedString(title, @"");
    tlabel.font = [UIFont systemFontOfSize: 14.0];
    //tlabel.backgroundColor = [UIColor grayColor];
    tlabel.textColor = [UIColor blueColor];
    tlabel.textAlignment = UITextAlignmentLeft;
    tlabel.autoresizingMask = 0;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:tlabel];

    return cell;
}

- (void)attachView:(UIView *)view
{
    [attachedView removeFromSuperview];
    [attachedView release];

    attachedView = [view retain];
    [self addSubview:view];
}

- (void)dealloc
{
    [attachedView release];
    [super dealloc];
}

@end
