//
//  DDGWebViewController.m
//  DuckDuckGo2
//
//  Created by Chris Heimark on 12/10/11.
//  Copyright (c) 2011 DuckDuckGo, Inc. All rights reserved.
//

#import "DDGWebViewController.h"

@implementation DDGWebViewController

@synthesize searchController;
@synthesize webView;
@synthesize params;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	webView.delegate = self;
	webView.scalesPageToFit = YES;
	callDepth = 0;

	self.searchController = [[DDGSearchController alloc] initWithNibName:@"DDGSearchController" view:self.view];
	searchController.searchHandler = self;
    searchController.state = eViewStateWebResults;
	searchController.search.text = webQuery;
	[searchController.searchButton setImage:[UIImage imageNamed:@"home40x37.png"] forState:UIControlStateNormal];

	[self loadURL:webURL];
}

- (void)dealloc
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}
	return YES;
}


#pragma mark - Search handler

-(void)loadHome {
	if(webView.canGoBack)
		[webView goBack];
	else
	    [self.navigationController popViewControllerAnimated:NO];
}

-(void)loadQuery:(NSString *)query {
    webQuery = query; // if the view hasn't loaded yet, setting search text won't work, so we need to save the query to load it later
    searchController.search.text = query;
    
    if(query) {
        NSString *url = [NSString stringWithFormat:@"https://duckduckgo.com/?q=%@&ko=-1", [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self loadURL:url];
    }
}

-(void)loadURL:(NSString *)url {
    if(url) {
        webURL = url; // if the view hasn't loaded yet, loadRequest: won't work, so we need to save the URL to load it later
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

#pragma mark - web view deleagte

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (++callDepth == 1)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (--callDepth <= 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		callDepth = 0;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if (--callDepth <= 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		callDepth = 0;
	}
}

@end
