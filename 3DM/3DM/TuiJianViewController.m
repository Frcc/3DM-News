//
//  TuiJianViewController.m
//  3DM
//
//  Created by Frcc on 15/5/4.
//  Copyright (c) 2015年 3DM. All rights reserved.
//

#import "TuiJianViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "tuijianTableViewCell.h"
#import "detailViewController.h"

@interface TuiJianViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *dataArr;
    IBOutlet UITableView *tbv;
}

@end

@implementation TuiJianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"推荐图文";
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    dataArr = [NSMutableArray array];
    
    NSArray *elements = [self.doc searchWithXPathQuery:@"//div[@class='tuwen']//ul//li"];//<div id="previous"
    
    for (TFHppleElement *e in elements) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:e.content forKey:@"title"];
        
        TFHppleElement *ee = e.children.firstObject;
        [dic setValue:[ee.attributes objectForKey:@"href"] forKey:@"url"];
        
        TFHppleElement *eee = ee.children.firstObject;
        NSString *ul = [eee.attributes objectForKey:@"src"];
        if ([ul containsString:@"//img"]) {
            ul = [ul stringByReplacingCharactersInRange:NSMakeRange(7, 6) withString:@""];
        }
        [dic setObject:ul forKey:@"imageurl"];
        
        [dataArr addObject:dic];
    }
    
    [tbv reloadData];
}

#pragma mark -
#pragma mark tableviewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    tuijianTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tuijianTableViewCell"];
    
    if (nil==cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"tuijianTableViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary *dic = [dataArr objectAtIndex:indexPath.row];
    
    [cell.imv setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"imageurl"]]];
    cell.title.text = [dic objectForKey:@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [dataArr objectAtIndex:indexPath.row];
    detailViewController *vc = [[detailViewController alloc] init];
    vc.url = [dic objectForKey:@"url"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
