
package org.tmurakam.presentationtimer;

import android.content.Intent;
import android.os.Bundle;
import android.preference.PreferenceActivity;
import android.preference.PreferenceScreen;

public class PrefActivity extends PreferenceActivity {
    //private static final String TAG = "PresenTimer";

    private Prefs mPrefs;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        addPreferencesFromResource(R.xml.pref);

        mPrefs = new Prefs(this);

        PreferenceScreen ps;
        Intent intent;

        for (int i = 1; i <= 3; i++) {
            ps = (PreferenceScreen)findPreference("_" + i + "bell");
            assert (ps != null);
            intent = new Intent(this, TimeSetActivity.class);
            intent.putExtra("kind", i);
            ps.setIntent(intent);
        }

        updateUi();
    }

    @Override
    public void onResume() {
        super.onResume();
        updateUi();
    }

    private void updateUi() {
        PreferenceScreen ps;

        for (int i = 1; i <= 3; i++) {
            ps = (PreferenceScreen)findPreference("_" + i + "bell");
            assert (ps != null);

            int time = mPrefs.getBellTime(i);
            String s = String.format("%02d:%02d", time / 3600, (time / 60) % 60);
            if (i == mPrefs.getCountDownTarget()) {
                s += ", ";
                s += getResources().getString(R.string.end_time);
            }
            ps.setSummary(s);
        }
    }
}
