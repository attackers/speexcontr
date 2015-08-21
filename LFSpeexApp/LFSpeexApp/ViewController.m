//
//  ViewController.m
//  LFSpeexApp
//
//  Created by attack on 15/7/20.
//  Copyright (c) 2015年 attack. All rights reserved.
//

#import "ViewController.h"
#import "SpeexAllHeader.h"
#import <iflyMSC/iflyMSC.h>
#import "PcmPlayer.h"
#import "PcmPlayerDelegate.h"

#import "BDVoiceRecognitionClient.h"
#import "BDVRRawDataRecognizer.h"
#define AppID @"6502401"
#define APIKey @"FKXW1dKijwYGz8sWrlv2cKVy"
#define SecretKey @"ffedadca0bc3b34286401dd5849cc3a2"
#define MAX_NB_BYTES 200
#define iflyAppid @"55bb53f2"
@interface ViewController ()<IFlySpeechRecognizerDelegate,MVoiceRecognitionClientDelegate>
{
    IFlySpeechUnderstander *_iflySpeechRecognizer;
    BDVRRawDataRecognizer *fileRecognizer;
}
int InitSpeexDecode(void);
int SpeexDecode(short *pPcm,char* pCode,short maxPcmLen,short maxCodeLen);
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pcmOutData = [NSMutableData data];
    NSString *initString = [[NSString alloc]initWithFormat:@"appid=%@",@"55b58286"];
    [IFlySpeechUtility createUtility:initString];
//
////
//    NSString *stringPath = [[NSBundle mainBundle]pathForResource:@"手机APP收到的编码数组 -不带格式 " ofType:@"txt"];
//    NSData *PCMData = [NSData dataWithContentsOfFile:stringPath];
//    
//
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Documentation"];
//
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL tag = [manager fileExistsAtPath:path isDirectory:NULL];
    
    if (!tag) {
        tag =  [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        path = [path stringByAppendingPathComponent:@"语音PCM.pcm"];
        
    }else{
        path = [path stringByAppendingPathComponent:@"语音PCM.pcm"];
    }
  NSFileManager *fileManager =  [[NSFileManager alloc]init];
  BOOL ok = [fileManager createFileAtPath:path contents:nil attributes:nil];
    if (ok) {
//        [subData writeToFile:path atomically:NO];

    }

    
    NSString *stringPath = [[NSBundle mainBundle]pathForResource:@"VoiceSpeex" ofType:@"dat"];

    const char *stringCC = [stringPath UTF8String];
    NSMutableData *getFileData = [NSMutableData data];
    FILE *fStream;
   fStream = fopen(stringCC, "r");
    if (fStream == NULL) {
        return;
    }
    char outChar[20];
    
    SpeexBits bits;
    void *de_code;
    speex_bits_init(&bits);
    de_code = speex_decoder_init(&speex_nb_mode);
    
    int frame_size;
  int ctl =  speex_decoder_ctl(de_code, SPEEX_GET_FRAME_SIZE, &frame_size);
    short output_frame[160];
    
    while (!feof(fStream)) {
        int n_len = fread(outChar, sizeof(char), 20, fStream);
        speex_bits_read_from(&bits, outChar, sizeof(outChar));
        [getFileData appendBytes:outChar length:sizeof(outChar)];
        if (n_len == 20) {
            int deco = speex_decode_int(de_code, &bits, output_frame);
            [_pcmOutData appendBytes:output_frame length:sizeof(output_frame)];
        }
    }

    speex_bits_destroy(&bits);
    speex_decoder_destroy(de_code);
    fclose(fStream);
    
    
    NSArray *savePath =  NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectorysave = [savePath objectAtIndex:0];
    NSString *pathsaveData = [documentsDirectorysave stringByAppendingPathComponent:@"/Documentation"];
    
    NSFileManager *managers = [NSFileManager defaultManager];
    BOOL tags = [managers fileExistsAtPath:pathsaveData isDirectory:NULL];
    
    if (!tags) {
        tags =  [managers createDirectoryAtPath:pathsaveData withIntermediateDirectories:YES attributes:nil error:nil];
        pathsaveData = [pathsaveData stringByAppendingPathComponent:@"语音PCM.pcm"];
        
    }else{
        pathsaveData = [pathsaveData stringByAppendingPathComponent:@"语音PCM.pcm"];
    }

    NSFileManager *fileManagers =  [[NSFileManager alloc]init];
    ok = [fileManagers createFileAtPath:pathsaveData contents:nil attributes:nil];
    ok =  [_pcmOutData writeToFile:pathsaveData atomically:NO];
    [self initIFlySpeechUnderstander];
    
}
#pragma  mark ******************* iFlySpeechUnder ************************

- (void)initIFlySpeechUnderstander
{
    _iflySpeechRecognizer = [IFlySpeechUnderstander sharedInstance];
    _iflySpeechRecognizer.delegate = self;
    [_iflySpeechRecognizer setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    [_iflySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
    [_iflySpeechRecognizer setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
    [_iflySpeechRecognizer setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    [_iflySpeechRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
    [_iflySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
    [_iflySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
//    [_iflySpeechRecognizer setParameter:@"2.0" forKey:[IFlySpeechConstant NLP_VERSION]];
    [_iflySpeechRecognizer setParameter:@"-1" forKey:[IFlySpeechConstant AUDIO_SOURCE]];
    
    NSString *stringPath = [[NSBundle mainBundle]pathForResource:@"voice" ofType:@"dat"];
    [_iflySpeechRecognizer startListening];
    
    NSArray *savePath =  NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectorysave = [savePath objectAtIndex:0];
    NSString *pathsaveData = [documentsDirectorysave stringByAppendingPathComponent:@"/Documentation/语音PCM.pcm"];
    

    NSData *data = [NSData dataWithContentsOfFile:pathsaveData];    //从文件中读取音频

    int count = 10;
    unsigned long audioLen = data.length/count;
    
    
    for (int i =0 ; i< count-1; i++) {    //分割音频
        char * part1Bytes = malloc(audioLen);
        NSRange range = NSMakeRange(audioLen*i, audioLen);
        [data getBytes:part1Bytes range:range];
        NSData * part1 = [NSData dataWithBytes:part1Bytes length:audioLen];
        
        int ret = [_iflySpeechRecognizer writeAudio:part1];//写入音频，让SDK识别
        free(part1Bytes);
        
        
        if(!ret) {     //检测数据发送是否正常
            NSLog(@"%s[ERROR]",__func__);
            [_iflySpeechRecognizer stopListening];

            return;
        }
    }
    
    //处理最后一部分
    unsigned long writtenLen = audioLen * (count-1);
    char * part3Bytes = malloc(data.length-writtenLen);
    NSRange range = NSMakeRange(writtenLen, data.length-writtenLen);
    [data getBytes:part3Bytes range:range];
    NSData * part3 = [NSData dataWithBytes:part3Bytes length:data.length-writtenLen];
    
    [_iflySpeechRecognizer writeAudio:part3];
    free(part3Bytes);
    [_iflySpeechRecognizer stopListening];//音频数据写入完成，进入等待状态

}
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast
{
//    NSLog(@"results : %@",results);
    NSDictionary *dic = results[0];
//    NSArray *array = [dic allKeys];
//    if (array!=nil) {
//        
//        NSString *string = array[0];
//        NSLog(@"%@",string);
//    }
    NSMutableString *result = [[NSMutableString alloc] init];
//    NSDictionary *dic = results [0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    NSLog(@"听写结果：%@",result);
}
- (void)onError:(IFlySpeechError *)errorCode
{
    NSLog(@"Error:%@",errorCode.errorDesc);
    
}

- (void)onVolumeChanged:(int)volume
{

}

- (void)onBeginOfSpeech
{

}

- (void)onEndOfSpeech
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
