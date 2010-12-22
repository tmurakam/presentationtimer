
package org.tmurakam.presentationtimer;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class Prefs {
    private SharedPreferences mPrefs;

    private final static int[] DEFAULT_BELL_TIMES = {
            13, 15, 20
    };

    public Prefs(Context context) {
        mPrefs = PreferenceManager.getDefaultSharedPreferences(context.getApplicationContext());
    }

    public int getBellTime(int kind) {
        assert (1 <= kind && kind <= 3);
        int defValue = DEFAULT_BELL_TIMES[kind - 1] * 60;
        return mPrefs.getInt("bell" + kind + "Time", defValue);
    }

    public void setBellTime(int kind, int secs) {
        SharedPreferences.Editor editor = mPrefs.edit();
        editor.putInt("bell" + kind + "Time", secs);
        editor.commit();
    }

    public int getCountDownTarget() {
        return mPrefs.getInt("countDownTarget", 2);
    }

    public void setCountDownTarget(int kind) {
        SharedPreferences.Editor editor = mPrefs.edit();
        editor.putInt("countDownTarget", kind);
        editor.commit();
    }
}
