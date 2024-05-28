//
//  ViewController.m
//  DispatchAfterDemo
//
//  Created by 1084-Wangcl-Mac on 2024/5/28.
//  Copyright © 2024 Charles2021. All rights reserved.
//

#import "ViewController.h"

typedef void(^WWDelayedBlockHandle) (BOOL cancel);

@interface ViewController ()

@property (nonatomic, assign) WWDelayedBlockHandle delayedBlockHandle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 20202203;
    button.frame = CGRectMake((self.view.frame.size.width - 200) / 2, 100, 200, 40);
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitle:@"after开始" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(afterAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake((self.view.frame.size.width - 200) / 2, 160, 200, 40);
    cancel.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancel setTitle:@"after取消执行" forState:UIControlStateNormal];
    [cancel setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(afterCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.tag = 20202203;
    button2.frame = CGRectMake((self.view.frame.size.width - 200) / 2, 240, 200, 40);
    button2.titleLabel.font = [UIFont systemFontOfSize:13];
    [button2 setTitle:@"perform开始" forState:UIControlStateNormal];
    [button2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(performAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *cancel2 = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel2.frame = CGRectMake((self.view.frame.size.width - 200) / 2, 290, 200, 40);
    cancel2.titleLabel.font = [UIFont systemFontOfSize:13];
    [cancel2 setTitle:@"perform取消执行" forState:UIControlStateNormal];
    [cancel2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [cancel2 setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [cancel2 addTarget:self action:@selector(performCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel2];
}

#pragma mark - buttonActions
- (void)afterAction:(UIButton *)button {
    NSLog(@"buttonAction_____开始测试dispatch_after执行");
    [self afterTestAction];
}

- (void)afterTestAction {
    _delayedBlockHandle = perform_block_after_delay(3.0, ^{
       NSLog(@"buttonAction_____3s后执行dispatch_after代码块中的内容");
    });
}


- (void)afterCancel:(UIButton *)button {
    NSLog(@"buttonAction_____取消dispatch_after代码块的执行");
    cancel_delayed_block(_delayedBlockHandle);
}


- (void)performAction:(UIButton *)button {
    NSLog(@"buttonAction_____开始测试perform_after执行");
    [self performSelector:@selector(performTestAction) withObject:nil afterDelay:3];
}

- (void)performTestAction {
    NSLog(@"buttonAction_____3s后执行perform_after代码块中的内容");
}

- (void)performCancel:(UIButton *)button {
    NSLog(@"buttonAction_____取消perform_after执行");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performTestAction) object:nil];
}


static WWDelayedBlockHandle perform_block_after_delay(CGFloat seconds, dispatch_block_t block) {
    if (block == nil) {
        return nil;
    }
      
    __block dispatch_block_t blockToExecute = [block copy];
    __block WWDelayedBlockHandle delayHandleCopy = nil;
      
    WWDelayedBlockHandle delayHandle = ^(BOOL cancel) {
        if (!cancel && blockToExecute) {
            blockToExecute();
        }
          
        // Once the handle block is executed, canceled or not, we free blockToExecute and the handle.
        // Doing this here means that if the block is canceled, we aren't holding onto retained objects for any longer than necessary.
#if !__has_feature(objc_arc)
        [blockToExecute release];
        [delayHandleCopy release];
#endif
          
        blockToExecute = nil;
        delayHandleCopy = nil;
    };
    // delayHandle also needs to be moved to the heap.
    delayHandleCopy = [delayHandle copy];
      
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (nil != delayHandleCopy) {
            delayHandleCopy(NO);
        }
    });
      
    return delayHandleCopy;
}

static void cancel_delayed_block(WWDelayedBlockHandle delayedHandle) {
    if (nil == delayedHandle) {
        return;
    }
      
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        delayedHandle(YES);
    });
}


@end
