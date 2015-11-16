//
//  pinglunTableViewController.m
//  3DM
//
//  Created by Frcc on 15/11/16.
//  Copyright © 2015年 3DM. All rights reserved.
//

#import "pinglunTableViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "TFHpple.h"
#import "pinglunTableViewCell.h"

@interface pinglunTableViewController ()

@property (nonatomic,strong) NSMutableArray *titles;
@property (nonatomic,strong) NSMutableArray *comment_acts;
@property (nonatomic,strong) NSMutableArray *feedfonts;
@property (nonatomic,strong) NSMutableArray *comment_btnss;

@end

@implementation pinglunTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"评论";
    
    self.titles = [NSMutableArray array];
    self.comment_acts = [NSMutableArray array];
    self.feedfonts = [NSMutableArray array];
    self.comment_btnss = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"pinglunTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"pinglunTableViewCell"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];//<div class="miaoshu"> <div class="h3ke con">
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:[NSString stringWithFormat:@"http://www.3dmgame.com//plus/feedback.php?action=jsget&aid=%@",self.aid] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"%@",str);
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//li"];//<div id="previous"
        for (TFHppleElement *e in elements) {
            for (TFHppleElement *ee in e.children) {
                NSLog(@"%@ -- %@",[ee.attributes objectForKey:@"class"],ee.content);
                if ([[ee.attributes objectForKey:@"class"] isEqualToString:@"title"]) {
                    [self.titles addObject:ee.content];
                }
                if ([[ee.attributes objectForKey:@"class"] isEqualToString:@"comment_act"]) {
                    [self.comment_acts addObject:ee.content];
                }
                if ([[ee.attributes objectForKey:@"class"] isEqualToString:@"feedfont"]) {
                    [self.feedfonts addObject:ee.content];
                }
                if ([[ee.attributes objectForKey:@"class"] isEqualToString:@"comment_btns"]) {
                    [self.comment_btnss addObject:ee.content];
                }
            }
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    pinglunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pinglunTableViewCell" forIndexPath:indexPath];
    
    cell.titlelabel.text = self.titles[indexPath.row];
    cell.comment_actlabel.text = self.comment_acts[indexPath.row];
    cell.feedfontlabel.text = self.feedfonts[indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
