//
//  ViewController.m
//  mySpeechtoText
//
//  Created by BDAFshare on 3/6/17.
//  Copyright © 2017 RAD-INF. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<SFSpeechRecognizerDelegate>

@end

@implementation ViewController{
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *speechRecognitionTask;
    AVAudioEngine *audioEngine;
    AVAudioInputNode *inputNode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    audioEngine = [[AVAudioEngine alloc]init];
    self.txtFromSpeech.text = @"";
    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"vi-VN"];
    //NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:local];
    speechRecognizer.delegate = self;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL isButtonEnable = false;
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isButtonEnable = true;
                NSLog(@"Authorized");
                
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                isButtonEnable = false;
                NSLog(@"Denied");
                break;
            default:
                break;
                // update UI on the main thread
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.btnMicrophone.enabled = isButtonEnable;
        });
    }];
}

- (IBAction)btnTapped:(id)sender {
    
    if(audioEngine.isRunning){
        [audioEngine stop];
        [recognitionRequest endAudio];
        self.btnMicrophone.enabled = false;
        [self.btnMicrophone setTitle:@"Start record" forState:UIControlStateNormal];
    } else {
        [self.btnMicrophone setTitle:@"Stop Record" forState:UIControlStateNormal];
        [self startRecording];
    }
}

-(void)startRecording {
    // Check if recognitionTask is running. If so, cancel the task and the recognition
    // SFSpeechRecognitionTask
    
    if (speechRecognitionTask != nil) {
        speechRecognitionTask = nil;
        [speechRecognitionTask cancel];
    }
    //prepare for the audio recording
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    self.txtFromSpeech.text = @"Please speak the business";
    
    NSError *error = nil;
    
    if(error == nil) {
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
        [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
        [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        
    } else{
        NSLog(@"audioSession properties weren't set because of an error.");
    }
    // recognitionRequest
    // use it to pass our audio data to Apple’s servers
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    inputNode = audioEngine.inputNode;
    inputNode = audioEngine.inputNode;
    
    //Check audioEngine as an audio input for recording. If not, we report a fatal erro
    if (inputNode == nil) {
        NSLog(@"AudioEngine has no input node");
    }
    
    //Check if the recognitionRequest object is instantiated and is not
    if (recognitionRequest == nil) {
        NSLog(@"Unable to create and SFSpeechAudioBufferRecognitionRequest object");
        
    }
    
    recognitionRequest.shouldReportPartialResults = YES;
    error = nil;
    
    
    speechRecognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable errorl) {
        
        BOOL isFinal;
        if (result != nil) {
            NSLog(@"Formatted String: %@ ",result.bestTranscription.formattedString);
            self.txtFromSpeech.text = result.bestTranscription.formattedString;
            
            
            [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(endRecordingAudio) userInfo:nil repeats:NO];
            
            isFinal = [result isFinal];
            //If there is no error or the result is final
            //stop audioEngine, recognitionRequest, recognitionTask, At the same time, we enable the Start Recording button
            if (isFinal) {
                [audioEngine stop];
                [inputNode removeTapOnBus: 0];
                recognitionRequest = nil;
                speechRecognitionTask = nil;
            }
            
            //[self.btnMicrophone setEnabled: true];
        }
        
        if (errorl) {
            NSLog(@"Error Description: %@", errorl);
            //[self.btnMicrophone setEnabled: true];
            //end
            NSLog(@"AudioEngine stopped");
            [audioEngine stop];
            [inputNode removeTapOnBus: 0];
            recognitionRequest = nil;
            speechRecognitionTask = nil;
            
        }
        [self.btnMicrophone setEnabled: true];
    }];
    
    
    AVAudioFormat *recodringFormat = [inputNode outputFormatForBus:0];
    
    [inputNode installTapOnBus:0 bufferSize:1024 format:recodringFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    NSError *error1;
    
    [audioEngine prepare];
    
    [audioEngine startAndReturnError:&error1];
    
    if (error1 != nil) {
        NSLog(@"Error discription: %@", error1.description);
    }
    
    self.txtFromSpeech.text = @"Let's speak, I am listening!";
    NSLog(@"Say something, I am listening!");
    
}


-(void)endRecordingAudio
{  
    NSLog(@"AudioEngine stopped");
    [audioEngine stop];
    [inputNode removeTapOnBus: 0];
    recognitionRequest = nil;
    speechRecognitionTask = nil;
}

-(void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available{
    if (available) {
        //self.btnMicrophone.enabled = true;
    } else {
        //self.btnMicrophone.enabled = false;
    }
}

@end
