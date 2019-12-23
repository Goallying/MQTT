//
//  ViewController.m
//  MQTT
//
//  Created by Lifee on 2019/12/23.
//  Copyright © 2019 Lifee. All rights reserved.
//

#import "ViewController.h"
#import <MQTTClient/MQTTClient.h>

@interface ViewController ()<MQTTSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *contentTF;

@property (nonatomic ,strong) MQTTSession * session ;
@property (nonatomic ,assign) BOOL  subscribe ;
@property (weak, nonatomic) IBOutlet UITextView *consoleTextView;
@property (weak, nonatomic) IBOutlet UILabel *subscribelb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)connect_unconnect:(UIButton *)sender {
//    MQTTSessionStatusCreated,
//    MQTTSessionStatusConnecting,
//    MQTTSessionStatusConnected,
//    MQTTSessionStatusDisconnecting,
//    MQTTSessionStatusClosed,
//    MQTTSessionStatusError
    switch (self.session.status) {
        case MQTTSessionStatusConnected:
        {
            [self.session disconnect];
        }
            break;
        case MQTTSessionStatusCreated: case MQTTSessionStatusClosed: case MQTTSessionStatusError:
        {
            [self.session connect];
        }
            break ;
        default:
            break;
    }
}

- (IBAction)subscribe_unsubscribe:(UIButton *)sender {
    
    if (self.subscribe) {
        [self.session unsubscribeTopic:@"MQTTClient"];
    }else {
        [self.session subscribeToTopic:@"MQTTClient" atLevel:MQTTQosLevelAtMostOnce];
    }
}

- (IBAction)publish:(UIButton *)sender {
    
    [self.session publishData:[self.contentTF.text dataUsingEncoding:NSUTF8StringEncoding]
                      onTopic:@"MQTTClient"
                       retain:NO
                          qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
        
        
        if (error) {
            NSLog(@"error------%@",error);
        }
    }];
}
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    
    NSString * datas = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString * text = self.consoleTextView.text ;
    text = [text stringByAppendingFormat:@"\n topic - %@ data - %@",topic ,datas];
    
    self.consoleTextView.text = text ;
    
}
- (void)subAckReceived:(MQTTSession *)session msgID:(UInt16)msgID grantedQoss:(NSArray<NSNumber *> *)qoss {
    self.subscribelb.text = @"Subscribed";
    self.subscribe = YES ;
}
- (void)unsubAckReceived:(MQTTSession *)session msgID:(UInt16)msgID {
    self.subscribelb.text = @"UnSubscribed";
       self.subscribe = NO ;
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error {
    switch (eventCode) {
        case MQTTSessionEventConnected:
        {
            self.navigationItem.title = @"Connected";
        }
            break;
        case MQTTSessionEventConnectionRefused:
        {
            self.navigationItem.title = @"Refused";
        }
            break;
        case MQTTSessionEventConnectionClosed:
        {
            self.navigationItem.title = @"Closed";
        }
            break;
        case MQTTSessionEventConnectionError:
        {
            self.navigationItem.title = @"Error";
        }
            break;
        case MQTTSessionEventProtocolError:
        {
            self.navigationItem.title = @"Protocol Error";
        }
            break;
        case MQTTSessionEventConnectionClosedByBroker:
        {
            self.navigationItem.title = @"Closed by Broker";
        }
            break;
        default:
            break;
    }
}

- (MQTTSession *)session {
    if (!_session) {
        _session = [[MQTTSession alloc]init];
        _session.transport = [[MQTTCFSocketTransport alloc]init];
        _session.transport.host = @"test.mosquitto.org" ;
        _session.transport.port = 1883 ;
        _session.delegate = self ;
    }
    return _session ;
}
@end
