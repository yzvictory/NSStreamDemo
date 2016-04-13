//
//  ViewController.m
//  NSStreamDemo
//
//  Created by yz on 16/4/8.
//  Copyright © 2016年 DeviceOne. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>

@interface ViewController ()<NSStreamDelegate>
{
    NSMutableData *data;
}

@property (nonatomic,assign) NSInteger location;
@property (nonatomic,assign) unsigned long long fileSize;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    data = [NSMutableData data];
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"mkfile" ofType:@"txt"];
    [self readStream:filePath];
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *outputPath = [doc stringByAppendingPathComponent:@"local.txt"];
    [self writeStream:outputPath];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil];
    unsigned long long length = [fileAttributes fileSize];
    self.fileSize = length;
}
- (void)setUpOutputStreamForFile:(NSString *)path
{
    NSOutputStream *outputStream = [[NSOutputStream alloc]initToFileAtPath:path append:YES];
    outputStream.delegate = self;
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
    {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[2048];
            NSInteger len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:2048];  // 读取数据
            if (len) {
                [data appendBytes:buf length:len];
            }
        }
        break;
        case NSStreamEventEndEncountered:
        {
            [aStream close];
        }
        break;
        case NSStreamEventHasSpaceAvailable:
        {
            NSInteger bufSize = 2048;
            uint8_t buf[bufSize];
            [data getBytes:buf length:bufSize];
            NSOutputStream *writeStream = (NSOutputStream *)aStream;
            NSInteger len = [writeStream write:buf maxLength:sizeof(buf)];
            [data setLength:0];
            self.location += len;
            if (self.location>self.fileSize) {
                NSLog(@"NSStreamEventEndEncountered");
                [aStream close];
            }
        }
        break;
        default:
        break;
    }
}

- (void)readStream:(NSString *)filePath
{
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
}

- (void)writeStream:(NSString *)filePath
{
    NSOutputStream *writeStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
    [writeStream setDelegate:self];
    
    [writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [writeStream open];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
