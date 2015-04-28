//
//  detailViewController.m
//  3DM
//
//  Created by Frcc on 15-4-28.
//  Copyright (c) 2015年 3DM. All rights reserved.
//

#import "detailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "TFHpple.h"
#import "M80AttributedLabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface detailViewController (){
    NSMutableArray *txtData;
}

@end

@implementation detailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    txtData = [NSMutableArray array];
    
    [self getData];
}

static UIAlertView *av=nil;

- (void)getData{
    NSString *urlStr =self.url;
    
    if (self.page==0) {
        self.page=1;
    }
    
    self.navigationItem.rightBarButtonItem=nil;
    self.title = [NSString stringWithFormat:@"第%d页",self.page];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];//<div class="miaoshu"> <div class="h3ke con">
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject) {
        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[contains(@class,'con')]//div[2]"];//<div id="previous"
        
        for (TFHppleElement *e in elements) {
            for (TFHppleElement *ee in e.children) {
                if ([[ee.attributes objectForKey:@"class"] isEqualToString:@"page_fenye"]) {
                    NSLog(@"3page_fenye");
                    UIBarButtonItem *rbtn = [[UIBarButtonItem alloc] initWithTitle:@"下一页" style:UIBarButtonItemStylePlain target:self action:@selector(nexnpage)];
                    self.navigationItem.rightBarButtonItem = rbtn;
                    break;
                }
                for (TFHppleElement *eee in ee.children) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:eee.content forKey:@"text"];
                    if ([eee.attributes objectForKey:@"src"]) {
                        [dic setObject:[eee.attributes objectForKey:@"src"] forKey:@"imageurl"];
                    }
                    [txtData addObject:dic];
                    for (TFHppleElement *eeee in eee.children) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        if ([eeee.attributes objectForKey:@"src"]) {
                            [dic setObject:[eeee.attributes objectForKey:@"src"] forKey:@"imageurl"];
                        }
                        [txtData addObject:dic];
                    }
                }
            }
        }
        
        [self showTxt];
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        if (av) {
            [av dismissWithClickedButtonIndex:0 animated:YES];
            av = nil;
        }
        av = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self.navigationController popViewControllerAnimated:YES];
        [self performSelector:@selector(dismidd) withObject:nil afterDelay:0.5];
    }];
}

- (void)dismidd{
    if (av) {
        [av dismissWithClickedButtonIndex:0 animated:YES];
        av = nil;
    }
}

- (void)showTxt{
    M80AttributedLabel *label = [[M80AttributedLabel alloc]initWithFrame:self.view.bounds];
    label.lineSpacing = 5.0;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor whiteColor];
    label.paragraphSpacing = 10.0;
    label.text = @"";
    
    for (NSDictionary *dic in txtData) {
        NSString *text = [dic objectForKey:@"text"];
        NSString *imageurl = [dic objectForKey:@"imageurl"];//http://player.youku.com/player.php/sid/XOTQwMjU1NzQw/v.swf
        if ([imageurl containsString:@"swf"]) {
            NSArray *arr = [imageurl componentsSeparatedByString:@"/"];
            NSString *str = [arr objectAtIndex:arr.count-2];
            NSString *url = [NSString stringWithFormat:@"<iframe height=320 width=320 src=\"http://player.youku.com/embed/%@\" frameborder=0 allowfullscreen></iframe>",str];
            if ([imageurl containsString:@"tudou"]) {
                str = [arr objectAtIndex:4];
                 url = [NSString stringWithFormat:@"<iframe src=\"http://www.tudou.com/programs/view/html5embed.action?type=2&code=%@&lcode=%@&resourceId=45565876_04_05_99\" allowtransparency=\"true\" allowfullscreen=\"true\" allowfullscreenInteractive=\"true\" scrolling=\"no\" border=\"0\" frameborder=\"0\" style=\"width:320px;height:320px;\"></iframe>",str,str];
            }
            UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
            [wv loadHTMLString:url baseURL:nil];
            [wv setScalesPageToFit:YES];
            [label appendView:wv margin:UIEdgeInsetsMake(0, 0, 0, 0) alignment:M80ImageAlignmentCenter];
            [label appendText:@"\n"];
            continue;
        }
        [label appendText:text];
        if (imageurl) {
            UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
            imv.contentMode = UIViewContentModeScaleAspectFit;
            UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [av startAnimating];
            av.center = imv.center;
            [imv addSubview:av];
            [imv setImageWithURL:[NSURL URLWithString:imageurl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [av removeFromSuperview];
            }];
            [label appendView:imv margin:UIEdgeInsetsMake(0, 0, 0, 0) alignment:M80ImageAlignmentCenter];
        }
        [label appendText:@"\n"];
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 63, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:label];
    [self.view addSubview:scrollView];
    
    CGSize labelSize = [label sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 40, CGFLOAT_MAX)];
    [label setFrame:CGRectMake(20, 10, labelSize.width, labelSize.height)];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), labelSize.height + 20+64);
}

- (void)nexnpage{
    detailViewController *vc = [detailViewController new];
    vc.url = [self.url stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%d.html",self.page+1]];
    vc.page = self.page+1;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
