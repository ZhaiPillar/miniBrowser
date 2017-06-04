//
//  ViewController.m
//  MiniBrowser
//
//  Created by qzhai on 2/8/17.
//  Copyright © 2017 qzhai. All rights reserved.
//

#import "ViewController.h"

#import "HistoryTableViewController.h"
#import "FavoritesTableViewController.h"



@interface ViewController ()

@end

@interface ViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>
{
    UIWebView * _webView;//核心网页视图
    UITextField * _searchBar;//地址栏
    BOOL _isUp;//标记导航栏和工具栏是否处于隐藏状态
    UILabel * _titleLabel;//显示当前网页的网址
    UISwipeGestureRecognizer * _upSwipe;//上滑手势
    UISwipeGestureRecognizer * _downSwipe;//下滑手势
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    // 去掉弹簧效果
    _webView.scrollView.bounces = NO;
    //
    _webView.delegate = self;
    
    _isUp = NO;
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 20)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.baidu.com"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    [self createSearchBar];
    [self createGesture];
    [self createToolBar];
}

-(void) createSearchBar
{
    _searchBar = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 30)];
    _searchBar.borderStyle = UITextBorderStyleRoundedRect;
    
    UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [goBtn addTarget:self action:@selector(goWeb) forControlEvents:UIControlEventTouchUpInside];
    goBtn.frame = CGRectMake(0, 0, 30, 30);
    [goBtn setTitle:@"GO" forState:UIControlStateNormal];
    
    _searchBar.rightView = goBtn;
    _searchBar.rightViewMode = UITextFieldViewModeAlways;
    _searchBar.placeholder = @" 请输入网址";
    
    self.navigationItem.titleView = _searchBar;
}

-(void) goWeb
{
    if(_searchBar.text.length > 0)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@",_searchBar.text]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"输入的网址不能为空" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) createGesture
{
    _upSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(upSwipe)];
    _upSwipe.delegate = self;
    _upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    
    [_webView addGestureRecognizer:_upSwipe];
    
    _downSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(downSwipe)];
    _downSwipe.delegate = self;
    _downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    [_webView addGestureRecognizer:_downSwipe];
}

-(void) upSwipe
{

}

-(void) downSwipe
{

}

-(void) createToolBar
{
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *itemHistory = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(goHistory)];
    
    UIBarButtonItem *itemFavorites = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(goFavorites)];
    
    UIBarButtonItem *itemBack = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIBarButtonItem *itemForward = [[UIBarButtonItem alloc]initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
 
    self.toolbarItems = @[itemHistory,itemFavorites,itemBack,itemForward];
}

-(void) goHistory
{
    HistoryTableViewController *controller = [[HistoryTableViewController alloc]init];
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) goFavorites
{

}

-(void) goBack
{
    if([_webView canGoBack])
    {
        [_webView goBack];
    }
}

-(void) goForward
{
    if([_webView canGoForward])
    {
        [_webView goForward];
    }
}

-(void) loadURL:(NSString *)urlStr
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",urlStr]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_webView loadRequest:request];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _titleLabel.text = webView.request.URL.absoluteString;
    
    NSArray *array = [[NSUserDefaults standardUserDefaults]valueForKey:@"History"];
    if(!array)
    {
        array = [[NSArray alloc]init];
    }
    
    NSMutableArray *newArray = [[NSMutableArray alloc]initWithArray:array];
    [newArray addObject:_titleLabel.text];
    [[NSUserDefaults standardUserDefaults]setValue:newArray forKey:@"History"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer == _upSwipe || gestureRecognizer == _downSwipe)
    {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
