//
//  main.m
//  SpeexCC
//
//  Created by attack on 15/7/20.
//  Copyright (c) 2015年 attack. All rights reserved.
//

#import <Foundation/Foundation.h>
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        speex_bits_init(&bits);
        enc_state = speex_encoder_init(&speex_nb_mode);
        
        int frame_size;
        speex_encoder_ctl(enc_state, SPEEX_GET_FRAME_SIZE, &frame_size);        NSLog(@"Hello, World!");
    }
    return 0;
}
