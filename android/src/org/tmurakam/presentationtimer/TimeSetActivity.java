package org.tmurakam.presentationtimer;

import android.app.Activity;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import java.util.Timer;
import java.util.TimerTask;

public class TimeSetActivity extends Activity {
    private int mKind;
    private int mTime;
    private int mCountDownTarget;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.time_set);
        
        mKind = getIntent().getIntExtra("key", 1);
        
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);

        switch (mKind) {
            case 1:
                mTime = prefs.getInt("bell1Time", 13*60); //TODO: default value?
                break;
            case 2:
                mTime = prefs.getInt("bell2Time", 15*60);
                break;
            case 3:
                mTime = prefs.getInt("bell3Time", 20*60);
                break;
        }
        mCountDownTarget = prefs.getInt("countDownTarget", 2);
    }
}
