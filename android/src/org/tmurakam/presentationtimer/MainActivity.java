package org.tmurakam.presentationtimer;

import android.app.Activity;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.widget.Button;
import android.widget.TextView;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity {
    private int mCurrentTime = 0;
    
    //private Date suspendedTime;
    
    private boolean mIsCountDown = false;

    private MediaPlayer mBell1, mBell2, mBell3;
    
    private int mBell1Time, mBell2Time, mBell3Time;
    private int mCountDownTarget;
    
    private TextView mTextView;
    
    private Button mStartStopButton, mResetButton;
    
    private Timer mTimer;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        mTextView = (TextView)findViewById(R.id.timeView);
        mStartStopButton = (Button)findViewById(R.id.startStop);
        mResetButton = (Button)findViewById(R.id.reset);
        
        updateButtonStates();
        
        mBell1 = MediaPlayer.create(this, R.raw.bell1);
        mBell2 = MediaPlayer.create(this, R.raw.bell2);
        mBell3 = MediaPlayer.create(this, R.raw.bell3);

        /*
        color0 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        color1 = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
        color2 = [[UIColor alloc] initWithRed:1.0 green:0.2 blue:0.8 alpha:1.0];
        color3 = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        */
    }

    @Override
    public void onResume() {
        super.onResume();

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        mBell1Time = prefs.getInt("bell1Time", 13*60);
        mBell2Time = prefs.getInt("bell2Time", 15*60);
        mBell3Time = prefs.getInt("bell3Time", 20*60);
        mCountDownTarget = prefs.getInt("countDownTarget", 2);

        updateTimeLabel();
    }

    /**
       Start or stop timer (toggle)
    */
    public void onClickStartStop() {
        if (mTimer == null) {
            // start timer
            mTimer = new Timer(true);
            TimerTask task = new TimerTask() {
                @Override
                public void run() {
                    timerHandler();
                }
            };
            mTimer.schedule(task, 1000, 1000);

            // Disable auto lock when timer is running
            //[UIApplication sharedApplication].idleTimerDisabled = YES;
            // TODO: Android での実装。画面を消さない。
        } else {
            // stop timer
            mTimer.cancel();
            mTimer.purge();
            mTimer = null;
        
            // Enable auto lock
            // [UIApplication sharedApplication].idleTimerDisabled = NO;
        }
        
        updateButtonStates();
    }     

    /**
       Reset timer value
    */
    public void onClickReset() {
        mCurrentTime = 0;
        updateTimeLabel();
    }

    /**
       Ring bell manually
    */
    public void onClickBell() {
        mBell1.seekTo(0);
        mBell1.start();
    }

    /**
       Toggle count down mode
    */
    public void onClickTime() {
        mIsCountDown = !mIsCountDown;
        updateTimeLabel();
    }

    /**
      Timer handler : called for each 1 second.
    */
    private void timerHandler() {
        mCurrentTime ++;
	
        MediaPlayer p = null;
        if (mCurrentTime == mBell1Time) {
            p = mBell1;
        }
        else if (mCurrentTime == mBell2Time) {
            p = mBell2;
        }
        else if (mCurrentTime == mBell3Time) {
            p = mBell3;
        }
        if (p != null) {
            p.seekTo(0);
            p.start();
        }
        
        updateTimeLabel();
    }

    /**
     * Update button states
     */
    private void updateButtonStates() {
        if (mTimer == null) {
            mStartStopButton.setText("Start");
            mResetButton.setEnabled(true);
        } else {
            mStartStopButton.setText("Stop");
            mResetButton.setEnabled(false);
        }
    }
    
    /**
       Update time label
    */
    private void updateTimeLabel() {
        int t;
        if (!mIsCountDown) {
            t = mCurrentTime;
        } else {
            switch (mCountDownTarget)
                {
                case 1:
                    t = mBell1Time - mCurrentTime;
                    break;
                case 2:
                default:
                    t = mBell2Time - mCurrentTime;
                    break;
                case 3:
                    t = mBell3Time - mCurrentTime;
                    break;
                }
            if (t < 0) t = -t;
        }
        
        mTextView.setText(timeText(t));
        
        int col;
        if (mCurrentTime >= mBell3Time) {
            col = Color.RED; // 0xffff0000
        } else if (mCurrentTime >= mBell2Time) {
            col = 0xffff33cc;
        } else if (mCurrentTime >= mBell1Time) {
            col = Color.YELLOW; // 0xffffff00
        } else {
            col = Color.WHITE; // 0xffffffff
        }
		mTextView.setTextColor(col);
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
