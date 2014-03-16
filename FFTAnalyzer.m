//
//  FFTAnalyzer.m
//  SoundScaper
//
//  Created by Furuyama Yuuki on 3/16/14.
//  Copyright (c) 2014 Furuyama Yuuki. All rights reserved.
//

#import "FFTAnalyzer.h"

@implementation FFTAnalyzer

- (int)getMaxFreq:(float *)inData length:(int)length
{
    unsigned int sizeLog2 = (int)(log(length)/log(2));
    unsigned int size = 1 << sizeLog2;
    DSPSplitComplex splitComplex;
    splitComplex.realp = calloc(size, sizeof(float));
    splitComplex.imagp = calloc(size, sizeof(float));

    [self executeFFT:inData outData:splitComplex size:size];

    int maxFreq = 0;
    float maxFreqLen = 0;
    for (int i = 0; i < size; i++) {
        float real = splitComplex.realp[i];
        float imag = splitComplex.imagp[i];
        float len = sqrt(real * real + imag * imag);
        if (len > maxFreqLen) {
            maxFreq = i;
            maxFreqLen = len;
        }
    }
    NSLog(@"[%d] %f", maxFreq, maxFreqLen);

    free(splitComplex.realp);
    free(splitComplex.imagp);
    
    return maxFreq;
}

- (void)executeFFT:(float*)inData outData:(DSPSplitComplex)splitComplex size:(int)size
{
    unsigned int sizeLog2 = (int)(log(size)/log(2));

    FFTSetup fftSetup = vDSP_create_fftsetup(sizeLog2 + 1, FFT_RADIX2);
    float *window = calloc(size, sizeof(float));
    float *windowedInput = calloc(size, sizeof(float));
    vDSP_hann_window(window, size, 0);
    vDSP_vmul(inData, 1, window, 1, windowedInput, 1, size);

    for (int i = 0; i < size; i++) {
        splitComplex.realp[i] = windowedInput[i];
        splitComplex.imagp[i] = 0.0f;
    }

    // exec fft
    vDSP_fft_zrip(fftSetup, &splitComplex, 1, sizeLog2 + 1, FFT_FORWARD);

    // destruct
    free(window);
    free(windowedInput);
    vDSP_destroy_fftsetup(fftSetup);
}

@end
