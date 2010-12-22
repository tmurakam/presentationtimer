
package org.tmurakam.presentationtimer;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity {
    //private final static String TAG = "PresenTimer";

    private final static String KEY_CURRENT_TIME = "currentTime";

    private final static String KEY_IS_COUNTDOWN = "isCountDown";

    private final static String KEY_IS_TIMER_WORKING = "isTimerWorking";

    private final static String KEY_SUSPENDED_TIME = "suspendedTime";

    /** 現在時刻(秒) */
    private int mCurrentTime = 0;

    /** 表示モード:カウントダウンモードなら真 */
    private boolean mIsCountDown = false;

    /** プリファレンス　 */
    private Prefs mPrefs;

    /** 音声データ */
    private MediaPlayer mBell1, mBell2, mBell3;

    /** タイマ */
    private Timer mTimer;

    /** タイマハンドラ */
    private Handler mTimerHandler;

    /** 現在時間表示ビュー */
    private TextView mTextView;

    /** ボタン */
    private Button mStartStopButton, mResetButton;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.main);

        mTextView = (TextView)findViewById(R.id.timeView);
        mStartStopButton = (Button)findViewById(R.id.startStop);
        mResetButton = (Button)findViewById(R.id.reset);

        mTimerHandler = new Handler();

        mPrefs = new Prefs(this);

        mBell1 = MediaPlayer.create(this, R.raw.bell1);
        mBell2 = MediaPlayer.create(this, R.raw.bell2);
        mBell3 = MediaPlayer.create(this, R.raw.bell3);

        if (savedInstanceState != null) {
            restoreInstanceState(savedInstanceState);
        }
        updateTimeLabel();
        updateUiStates();
    }

    @Override
    public void onSaveInstanceState(Bundle st) {
        st.putInt(KEY_CURRENT_TIME, mCurrentTime);
        st.putBoolean(KEY_IS_COUNTDOWN, mIsCountDown);
        st.putBoolean(KEY_IS_TIMER_WORKING, mTimer != null);

        st.putLong(KEY_SUSPENDED_TIME, System.currentTimeMillis());
    }

    private void restoreInstanceState(Bundle st) {
        mCurrentTime = st.getInt(KEY_CURRENT_TIME);
        mIsCountDown = st.getBoolean(KEY_IS_COUNTDOWN);

        boolean isTimeWorking = st.getBoolean(KEY_IS_TIMER_WORKING);
        if (isTimeWorking) {
            long suspendedTime = st.getLong(KEY_SUSPENDED_TIME);
            long elapsed = (System.currentTimeMillis() - suspendedTime) / 1000;

            mCurrentTime += elapsed;

            startTimer();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        updateTimeLabel();
    }

    /**
     * Start or stop timer (toggle)
     */
    public void onClickStartStop(View v) {
        if (mTimer == null) {
            startTimer();
        } else {
            stopTimer();
        }
        updateUiStates();
    }

    private void startTimer() {
        assert (mTimer == null);

        mTimer = new Timer(true);
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                mTimerHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        timerHandler();
                    }
                });
            }
        };
        mTimer.schedule(task, 1000, 1000);
    }

    private void stopTimer() {
        assert (mTimer != null);
        mTimer.cancel();
        mTimer.purge();
        mTimer = null;
    }

    /**
     * Reset timer value
     */
    public void onClickReset(View v) {
        mCurrentTime = 0;
        updateTimeLabel();
    }

    /**
     * Ring bell manually
     */
    public void onClickBell(View v) {
        mBell1.seekTo(0);
        mBell1.start();
    }

    /**
     * Toggle count down mode
     */
    public void onClickTime() {
        mIsCountDown = !mIsCountDown;
        updateTimeLabel();
    }

    /**
     * Timer handler : called for each 1 second.
     */
    private void timerHandler() {
        mCurrentTime++;

        MediaPlayer p = null;
        if (mCurrentTime == mPrefs.getBellTime(1)) {
            p = mBell1;
        } else if (mCurrentTime == mPrefs.getBellTime(2)) {
            p = mBell2;
        } else if (mCurrentTime == mPrefs.getBellTime(3)) {
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
    private void updateUiStates() {
        if (mTimer == null) {
            mStartStopButton.setText(R.string.start);
            mResetButton.setEnabled(true);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        } else {
            mStartStopButton.setText(R.string.pause);
            mResetButton.setEnabled(false);
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    }

    /**
     * Update time label
     */
    private void updateTimeLabel() {
        int t;
        if (!mIsCountDown) {
            t = mCurrentTime;
        } else {
            int target = mPrefs.getBellTime(mPrefs.getCountDownTarget());
            t = target - mCurrentTime;
            if (t < 0)
                t = -t;
        }

        mTextView.setText(timeText(t));

        int col;
        if (mCurrentTime >= mPrefs.getBellTime(3)) {
            col = Color.RED; // 0xffff0000
        } else if (mCurrentTime >= mPrefs.getBellTime(2)) {
            col = 0xffff33cc;
        } else if (mCurrentTime >= mPrefs.getBellTime(1)) {
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

    // --- Menu
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        new MenuInflater(getApplication()).inflate(R.menu.main_menu, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Intent intent;

        switch (item.getItemId()) {
            case R.id.menu_preferences:
                intent = new Intent(this, PrefActivity.class);
                startActivity(intent);
                return true;

            case R.id.menu_help:
                intent = new Intent(this, InfoActivity.class);
                startActivity(intent);
                return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
