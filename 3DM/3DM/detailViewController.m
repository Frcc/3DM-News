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
#import "myImv.h"

#define BackGestureOffsetXToBack 80//>80 show pre vc

@interface detailViewController (){
    NSMutableArray *txtData;
    UIImageView *gesimv;
}

@property (nonatomic, strong) UIPanGestureRecognizer *leftSwipeGestureRecognizer;

@end

@implementation detailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.leftSwipeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    
    txtData = [NSMutableArray array];
    
    [self getData];
}

static UIAlertView *av=nil;

- (void)getData{
    [txtData removeAllObjects];
    NSString *urlStr =self.url;
    
    if (self.page==0) {
        self.page=1;
    }
    
    self.navigationItem.rightBarButtonItem=nil;
    self.title = [NSString stringWithFormat:@"第%d页",self.page];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];//<div class="miaoshu"> <div class="h3ke con">
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject) {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//div[contains(@class,'con')]//div[2]"];//<div id="previous"
        
        for (TFHppleElement *e in elements) {
            for (TFHppleElement *ee in e.children) {
                if ([[ee.attributes objectForKey:@"class"] isEqualToString:@"page_fenye"]) {
                    UIBarButtonItem *rbtn = [[UIBarButtonItem alloc] initWithTitle:@"下一页" style:UIBarButtonItemStylePlain target:self action:@selector(nexnpage)];
                    self.navigationItem.rightBarButtonItem = rbtn;
                    break;
                }
                for (TFHppleElement *eee in ee.children) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:eee.content forKey:@"text"];
                    if ([eee.attributes objectForKey:@"src"]) {
                        NSString *ul = [eee.attributes objectForKey:@"src"];
                        if ([ul containsString:@"//img"]) {
                            ul = [ul stringByReplacingCharactersInRange:NSMakeRange(7, 6) withString:@""];
                        }
                        [dic setObject:ul forKey:@"imageurl"];
                    }
                    [txtData addObject:dic];
                    for (TFHppleElement *eeee in eee.children) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        if ([eeee.attributes objectForKey:@"src"]) {
                            NSString *ul = [eeee.attributes objectForKey:@"src"];
                            if ([ul containsString:@"//img"]) {
                                ul = [ul stringByReplacingCharactersInRange:NSMakeRange(7, 6) withString:@""];
                            }
                            [dic setObject:ul forKey:@"imageurl"];
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
        if (self.page>2) {
            self.url = [self.url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d.html",self.page] withString:[NSString stringWithFormat:@"_%d.html",self.page-1]];
        }else{
            self.url = [self.url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d.html",self.page] withString:[NSString stringWithFormat:@".html"]];
        }
        self.page--;
        if (self.page<1) {
            self.page=1;
        }
        self.title = [NSString stringWithFormat:@"第%d页",self.page];
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
    M80AttributedLabel *label = [[M80AttributedLabel alloc]initWithFrame:[UIScreen mainScreen].bounds];
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
            NSString *url = [NSString stringWithFormat:@"<iframe height=280 width=280 src=\"http://player.youku.com/embed/%@\" frameborder=0 allowfullscreen></iframe>",str];
            if ([imageurl containsString:@"tudou"]) {
                str = [arr objectAtIndex:4];
                 url = [NSString stringWithFormat:@"<iframe src=\"http://www.tudou.com/programs/view/html5embed.action?type=2&code=%@&lcode=%@&resourceId=45565876_04_05_99\" allowtransparency=\"true\" allowfullscreen=\"true\" allowfullscreenInteractive=\"true\" scrolling=\"no\" border=\"0\" frameborder=\"0\" style=\"width:280px;height:280px;\"></iframe>",str,str];
            }
            UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
            [wv loadHTMLString:url baseURL:nil];
            [wv setScalesPageToFit:NO];
            wv.scrollView.scrollEnabled = NO;
            [label appendView:wv margin:UIEdgeInsetsMake(0, 0, 0, 0) alignment:M80ImageAlignmentCenter];
            [label appendText:@"\n"];
            continue;
        }
        [label appendText:text];
        if (imageurl) {
            myImv *imv = [[myImv alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
            imv.contentMode = UIViewContentModeScaleAspectFit;
            UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [av startAnimating];
            av.center = imv.center;
            [imv addSubview:av];
            
            [imv setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:nil options:SDWebImageProgressiveDownload|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [av removeFromSuperview];
            }];
          
            [label appendView:imv margin:UIEdgeInsetsMake(0, 0, 0, 0) alignment:M80ImageAlignmentCenter];
        }
        [label appendText:@"\n"];
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:label];
    [self.view addSubview:scrollView];
    
    CGSize labelSize = [label sizeThatFits:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 40, CGFLOAT_MAX)];
    [label setFrame:CGRectMake(20, 10, labelSize.width, labelSize.height)];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), labelSize.height + 20+64);
}

- (void)nexnpage{
    if (self.page>1) {
        self.url = [self.url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d.html",self.page] withString:[NSString stringWithFormat:@"_%d.html",self.page+1]];
    }else{
        self.url = [self.url stringByReplacingOccurrencesOfString:@".html" withString:[NSString stringWithFormat:@"_%d.html",self.page+1]];
    }
    
    self.page = self.page+1;
    
    [self getData];
}

- (void)previouspage{
    if (self.page==1) {
        return;
    }
    if (self.page>2) {
        self.url = [self.url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d.html",self.page] withString:[NSString stringWithFormat:@"_%d.html",self.page-1]];
    }else{
        self.url = [self.url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%d.html",self.page] withString:[NSString stringWithFormat:@".html"]];
    }
    
    self.page = self.page-1;
    
    [self getData];
}

- (void)handleSwipes:(UIPanGestureRecognizer *)sender
{
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        [self.navigationController.view addSubview:[self getImageFromView:self.navigationController.view]];
//    }
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
//            //next
//            [self nexnpage];
//        }
//        
//        if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
//            //previous
//            [self previouspage];
//        }
//    }
    
    CGPoint startPanPoint = CGPointZero;
    if (sender.state==UIGestureRecognizerStateBegan) {
        gesimv = [self getImageFromView:self.navigationController.view];
        [self.navigationController.view addSubview:gesimv];
        startPanPoint = gesimv.frame.origin;
        CGPoint velocity=[sender velocityInView:self.view];
        if(velocity.x!=0){
//            [self willShowPreViewController];
        }
        return;
    }
    CGPoint currentPostion = [sender translationInView:self.view];
    CGFloat xoffset = startPanPoint.x + currentPostion.x;
    CGFloat yoffset = startPanPoint.y + currentPostion.y;
    if (xoffset>0) {//向右滑
                if (true) {
                    xoffset = xoffset>self.view.frame.size.width?self.view.frame.size.width:xoffset;
                }else{
                    xoffset = 0;
                }
    }else if(xoffset<0){//向左滑
        if (true) {
            xoffset = xoffset<-self.view.frame.size.width?-self.view.frame.size.width:xoffset;
        }else{
            xoffset = 0;
        }
    }
    if (!CGPointEqualToPoint(CGPointMake(xoffset, yoffset), gesimv.frame.origin)) {
        [self layoutCurrentViewWithOffset:UIOffsetMake(xoffset, yoffset)];
    }
    if (sender.state==UIGestureRecognizerStateEnded) {
        if (gesimv.frame.origin.x<0) {
            if (gesimv.frame.origin.x>-BackGestureOffsetXToBack){
                [self hidePreViewControllerp];
            }else{
                [self showPreViewControllerp];
                while (self.view.subviews.lastObject) {
                    [self.view.subviews.lastObject removeFromSuperview];
                }
                [self nexnpage];
            }
        }else{
            if (gesimv.frame.origin.x<BackGestureOffsetXToBack){
                [self hidePreViewController];
            }else{
                [self showPreViewController];
                while (self.view.subviews.lastObject) {
                    [self.view.subviews.lastObject removeFromSuperview];
                }
                [self previouspage];
            }
        }
    }
}

-(void)layoutCurrentViewWithOffset:(UIOffset)offset{
    [gesimv setFrame:CGRectMake(offset.horizontal, self.view.bounds.origin.y, self.view.frame.size.width, gesimv.frame.size.height)];
    if (offset.horizontal>=0) {
        [self.view setFrame:CGRectMake(offset.horizontal/2-self.view.frame.size.width/2, self.view.bounds.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    }else{
        [self.view setFrame:CGRectMake(self.view.frame.size.width/2+offset.horizontal/2, self.view.bounds.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

-(void)showPreViewController{
    UIView *currentView = gesimv;
    NSTimeInterval animatedTime = 0;
    animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        [self layoutCurrentViewWithOffset:UIOffsetMake(self.view.frame.size.width, 0)];
    } completion:^(BOOL finished) {
        [gesimv removeFromSuperview];
    }];
}
-(void)hidePreViewController{
    UIView *currentView = gesimv;
    NSTimeInterval animatedTime = 0;
    animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        [self layoutCurrentViewWithOffset:UIOffsetMake(0, 0)];
    } completion:^(BOOL finished) {
        [gesimv removeFromSuperview];
    }];
}

-(void)showPreViewControllerp{
    UIView *currentView = gesimv;
    NSTimeInterval animatedTime = 0;
    animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        [self layoutCurrentViewWithOffset:UIOffsetMake(-self.view.frame.size.width, 0)];
    } completion:^(BOOL finished) {
        [gesimv removeFromSuperview];
    }];
}
-(void)hidePreViewControllerp{
    UIView *currentView = gesimv;
    NSTimeInterval animatedTime = 0;
    animatedTime = ABS(self.view.frame.size.width - currentView.frame.origin.x) / self.view.frame.size.width * 0.35;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        [self layoutCurrentViewWithOffset:UIOffsetMake(0, 0)];
    } completion:^(BOOL finished) {
        [gesimv removeFromSuperview];
    }];
}

-(UIImageView *)getImageFromView:(UIView *)theView{
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, 2.0);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *imv = [[UIImageView alloc] initWithImage:image];
    imv.layer.masksToBounds = YES;
    imv.layer.borderColor = [UIColor darkGrayColor].CGColor;
    imv.layer.borderWidth=1;
    return imv;
}

@end
