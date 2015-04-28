//
//  ViewController.m
//  3DM
//
//  Created by Frcc on 15-4-28.
//  Copyright (c) 2015年 3DM. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TFHpple.h"
#import "MJRefresh.h"
#import <Foundation/NSCharacterSet.h>
#import "TableViewCell.h"

NSString *const MJTableViewCellIdentifier = @"Cell";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *dataArr;
    IBOutlet UITableView *tbv;
    MJRefreshHeaderView *_header;
    NSString *transUrl;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dataArr = [NSMutableArray array];
    
     [tbv registerClass:[UITableViewCell class] forCellReuseIdentifier:MJTableViewCellIdentifier];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
    
    [self addHeader];
}

- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = tbv;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
    // 进入刷新状态就会回调这个Block
        
        [self loadData];
        
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
//                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
//                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
//                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    [header beginRefreshing];
    _header = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [tbv reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

- (void)loadData{
    NSString *urlStr =@"http://www.3dmgame.com/";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='previous']//li | //div[@id='next']//li"];//<div id="previous"
        
        for (TFHppleElement *e in elements) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            TFHppleElement *datedata = [[e children] objectAtIndex:0];
            //            NSLog(@"%@\t",datedata.content);
            [dic setObject:datedata.content forKey:@"date"];
            
            TFHppleElement *titledata = [[e children] objectAtIndex:1];
            //            NSLog(@"%@\t",titledata.content);
            [dic setObject:[titledata.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"title"];
            
            //            NSLog(@"%@\n",[titledata.attributes objectForKey:@"href"]);
            [dic setObject:[titledata.attributes objectForKey:@"href"] forKey:@"url"];
            if ([titledata.attributes objectForKey:@"style"]) {
                [dic setObject:@"1" forKey:@"red"];
            }else{
                [dic setObject:@"0" forKey:@"red"];
            }
            
            [dataArr addObject:dic];
        }
        
        [self performSelector:@selector(doneWithView:) withObject:_header afterDelay:0.0];
        
        [[NSUserDefaults standardUserDefaults] setObject:dataArr forKey:@"data"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self performSelector:@selector(doneWithView:) withObject:_header afterDelay:0.0];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = [dataArr objectAtIndex:indexPath.row];
    NSString *text = [dic objectForKey:@"title"];
    UIFont *fnt = [UIFont systemFontOfSize:18];
    CGRect tmpRect = [text boundingRectWithSize:CGSizeMake(290, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil] context:nil];
    return tmpRect.size.height+20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (nil==cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary *dic = [dataArr objectAtIndex:indexPath.row];
    cell.titleLabel.text = [dic objectForKey:@"title"];
    cell.dateLabel.text = [dic objectForKey:@"date"];
    
    if ([[dic objectForKey:@"red"] isEqualToString:@"1"]) {
        cell.titleLabel.textColor = [UIColor redColor];
    }else{
        cell.titleLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"qw.png"] style:UIBarButtonItemStyleDone target:nil action:nil];
//    [self.navigationItem setBackBarButtonItem:backItem];
//    self.navigationItem.backBarButtonItem.tintColor = [UIColor blackColor];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [dataArr objectAtIndex:indexPath.row];
    transUrl = [dic objectForKey:@"url"];
    [self performSegueWithIdentifier:@"detail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destination = segue.destinationViewController;
    if ([destination respondsToSelector:@selector(setUrl:)])
    {
        [destination setValue:transUrl forKey:@"url"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
