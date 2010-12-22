package org.tmurakam.presentationtimer;

import android.app.Activity;
import android.os.Bundle;

public class MainActivity extends Activity {
    private int currentTime = 0;
    //private Date suspendedTime;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        /*
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        bell1Time = [defaults integerForKey:@"bell1Time"];
        bell2Time = [defaults integerForKey:@"bell2Time"];
        bell3Time = [defaults integerForKey:@"bell3Time"];
        countDownTarget = [defaults integerForKey:@"countDownTarget"];
        if (bell1Time == 0) bell1Time = 13*60;
        if (bell2Time == 0) bell2Time = 15*60;
        if (bell3Time == 0) bell3Time = 20*60;
        if (countDownTarget == 0) countDownTarget = 2;
        isCountDown = NO;

        color0 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        color1 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
        color2 = [[UIColor alloc] initWithRed:1.0 green:0.2 blue:0.8 alpha:1.0];
        color3 = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
        sound_bell1 = [self loadWav:@"1bell"];
        sound_bell2 = [self loadWav:@"2bell"];
        sound_bell3 = [self loadWav:@"3bell"];
        */
    }

    @Override
    public void onResume() {
        super.onResume();
        updateTimeLabel();
    }

    /**
     * load WAV file from resource
     */
    private void loadWav(String name) {
        /*
        SystemSoundID sid;
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]];
        AudioServicesCreateSystemSoundID((CFURLRef)url, &sid);
        return sid;
        */
    }

    /**
       Start or stop timer (toggle)
    */
    private void onClickStartStop() {
        /*
          NSString *newTitle;
	
          if (timer == nil) {
          // start timer
          timer = [NSTimer scheduledTimerWithTimeInterval:1.0
          target:self 
          selector:@selector(timerHandler:) 
          userInfo:nil
          repeats:YES];
          [timer retain];
          newTitle = NSLocalizedString(@"Pause", @"");
          resetButton.enabled = NO;

          // Disable auto lock when timer is running
          [UIApplication sharedApplication].idleTimerDisabled = YES;
          } else {
          // stop timer
          [timer invalidate];
          [timer release];
          timer = nil;

          newTitle = NSLocalizedString(@"Start", @"");
          resetButton.enabled = YES;

          // Enable auto lock
          [UIApplication sharedApplication].idleTimerDisabled = NO;
          }
          [startStopButton setTitle:newTitle forState:UIControlStateNormal];
          [startStopButton setTitle:newTitle forState:UIControlStateHighlighted];
        */
    }     

    /**
       Reset timer value
    */
    public void onClickReset() {
        currentTime = 0;
        updateTimeLabel();
    }

    /**
       Ring bell manually
    */
    public void onClickBell() {
        // AudioServicesPlaySystemSound(sound_bell1);
    }

    /**
       Toggle count down mode
    */
    public void onClickTime() {
        isCountDown = !isCountDown;
        updateTimeLabel();
    }

    /**
      Timer handler : called for each 1 second.
    */
    private void timerHandler() {
        currentTime ++;
	
        if (currentTime == bell1Time) {
            //AudioServicesPlaySystemSound(sound_bell1);
        }
        else if (currentTime == bell2Time) {
            //AudioServicesPlaySystemSound(sound_bell2);
        }
        else if (currentTime == bell3Time) {
            //AudioServicesPlaySystemSound(sound_bell3);
        }
        
        updateTimeLabel();
    }

    /**
       Update time label
    */
    private void updateTimeLabel() {
        int t;
        if (!isCountDown) {
            t = currentTime;
        } else {
            switch (countDownTarget)
                {
                case 1:
                    t = bell1Time - currentTime;
                    break;
                case 2:
                default:
                    t = bell2Time - currentTime;
                    break;
                case 3:
                    t = bell3Time - currentTime;
                    break;
                }
            if (t < 0) t = -t;
        }
        timeLabel.text = [self timeText:t];

        UIColor *col;
        if (currentTime >= bell3Time) {
            col = color3;
        } else if (currentTime >= bell2Time) {
            col = color2;
        } else if (currentTime >= bell1Time) {
            col = color1;
        } else {
            col = color0;
        }
		
        timeLabel.textColor = col;
    }

    private String timeText(int n) {
        int min = n / 60;
        int sec = n % 60;
        String ts = String.format("%02d:%02d", min, sec);
        return ts;
    }

    private void showHelp() {
        /*
          InfoVC *vc = [[[InfoVC alloc] init] autorelease];
          UINavigationController *nv = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
          [self presentModalViewController:nv animated:YES];
        */
    }

    @Override
    public void onSaveInstanceState(Bundle st) {
        /*
        if (timer == nil) return; // do nothing
    
        // timer working. remember current time
        suspendedTime = [NSDate date];
        [suspendedTime retain];
        */
    }

    private void resumeInstanceState(Bundle st) {
        /*
        if (timer == nil) return; // do nothing
    
        if (suspendedTime == nil) return;
    
        // modify current time
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:suspendedTime];
        currentTime += interval;
        [suspendedTime release];
        suspendedTime = nil;
        */
    }       
}
