
package org.tmurakam.presentationtimer;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.CheckBox;
import android.widget.TimePicker;

public class TimeSetActivity extends Activity {
    private int mKind;

    private TimePicker mTimePicker;

    private CheckBox mCheckIsEndTime;

    private Prefs mPrefs;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setTheme(android.R.style.Theme_Dialog);
        setContentView(R.layout.time_set);

        mTimePicker = (TimePicker)findViewById(R.id.TimePicker);
        mCheckIsEndTime = (CheckBox)findViewById(R.id.CheckUseAsEndTime);

        mKind = getIntent().getIntExtra("kind", 1);

        mPrefs = new Prefs(this);
        int time = mPrefs.getBellTime(mKind);
        int hour = time / 3600;
        int min = (time / 60) % 60;

        mTimePicker.setIs24HourView(true);
        mTimePicker.setCurrentHour(hour);
        mTimePicker.setCurrentMinute(min);

        mCheckIsEndTime.setChecked(mKind == mPrefs.getCountDownTarget());
    }

    public void onClickOk(View v) {
        int hour = mTimePicker.getCurrentHour();
        int min = mTimePicker.getCurrentMinute();

        mPrefs.setBellTime(mKind, hour * 3600 + min * 60);
        if (mCheckIsEndTime.isChecked()) {
            mPrefs.setCountDownTarget(mKind);
        }
        finish();
    }

    public void onClickCancel(View v) {
        finish();
    }
}
