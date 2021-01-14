//
//  ViewController.m
//  Demoz
//
//  Created by chenxi on 2020/12/25.
//  Copyright © 2020 zhangjin. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "GSKeychain.h"

@interface Person : NSObject

@end

@implementation Person

//- (void)testMethod{
//    NSLog(@"testMethod");
//}

@end

@interface ViewController ()
{
    dispatch_semaphore_t semaphore;
    
}
@property(nonatomic,strong)NSMutableArray *array;
@end

@implementation ViewController
void fooMethod(id obj, SEL _cmd) {
    NSLog(@"Doing foo");
}

- (void)abcd {
    NSLog(@"abcd");
}
//- (void)testMethod{
//    NSLog(@"testMethod");
//}

#pragma mark —- Runtime消息转发1 动态解析方法
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    //若存在testMethod，执行
//    if (sel == @selector(testMethod)) {
//        //否则消息转发动态解析
//        class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
//        return YES;
//    }
//    return YES;
//}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    //若存在testMethod，执行
//    if (sel == @selector(testMethod)) {
//        //否则消息转发动态解析
//        class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
//        return YES;
//    }
    return YES;
}
#pragma mark —- Runtime消息转发2 备用接受者
//若动态解析resolveInstanceMethod没有实现对应方法，则转发其他对象执行
//resolveInstanceMethod返回YES或NO无所谓
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    if (aSelector == @selector(testMethod)) {
//        return [Person new];
//    }
//    return [super forwardingTargetForSelector:aSelector];
//}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

#pragma mark —- Runtime消息转发3 完整消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"testMethod"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;
    
    Person *p = [Person new];
    if ([p respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:p];
    }else {
      //  [self doesNotRecognizeSelector:sel]; //抛出异常
        NSLog(@"un implementation Method");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
//    GSKeychain * keyWraper = [GSKeychain systemKeychain];
////    [keyWraper setSecret:@"112233" forKey:@"Device_UUID"];
//    NSString * strGetUUID = [keyWraper secretForKey:@"Device_UUID"];
//    NSLog(@"strGetUUID: %@",strGetUUID);
    
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(10, 100, 100, 45);
    label.textColor = [UIColor orangeColor];
    [self.view addSubview:label];
    label.text = @"1111";
    
    
    UILabel *label2 = [UILabel new];
    label2.frame = CGRectMake(10, 200, 100, 45);
    label2.textColor = [UIColor orangeColor];
    [self.view addSubview:label2];
    label2.text = @"2222";

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer1,dispatch_walltime(NULL, 0),10.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer1, ^{
        label.text = @"_timer1";
    });
    dispatch_resume(_timer1);
    
    dispatch_source_t _timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer2,dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC),10.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer2, ^{
        label2.text = @"_timer2";
    });
    dispatch_resume(_timer2);

//    [self performSelector:@selector(testMethod)];
    
    //    int a = 9; //1001
    //    int b = 10;//1010
    //    a ^= b;//a 1001
    //           //b 1010
    //           //a 0011
    //    NSLog(@"a==== %d",a);//3
    //
    //    b ^= a;//a 0011
    //           //b 1010
    //           //b 1001
    //    NSLog(@"b==== %d",b);//9
    //
    //    a ^= b;//b 1001
    //           //a 0011
    //           //a 1010
    //    NSLog(@"a==== %d",a);//10
    //
//        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//            NSLog(@"session 1: %@",[NSThread currentThread]);
//            dispatch_semaphore_signal(sem);
//        });
//
//        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//            NSLog(@"session 2: %@",[NSThread currentThread]);
//            dispatch_semaphore_signal(sem);
//        });
//
//        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//            NSLog(@"session 3: %@",[NSThread currentThread]);
//        });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    semaphore =  dispatch_semaphore_create(1);
//    self.array = [NSMutableArray array];
//    for (int i=0; i<20; i++) {
//        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(test) object:nil];
//        [thread start];
//    }
}
- (void)test{
    NSLog(@"测试开始: %@",[NSThread currentThread]);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.array addObject:@"0"];
    dispatch_semaphore_signal(semaphore);
//    NSLog(@"测试结束: %d",self.array.count);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//        NSLog(@"session 1: %@",[NSThread currentThread]);
//        dispatch_semaphore_signal(sem);
//    });
//
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//        NSLog(@"session 2: %@",[NSThread currentThread]);
//        dispatch_semaphore_signal(sem);
//    });
//
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
//        NSLog(@"session 3: %@",[NSThread currentThread]);
//    });
}

@end
