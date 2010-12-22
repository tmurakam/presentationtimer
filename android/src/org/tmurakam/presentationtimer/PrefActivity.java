package org.tmurakam.presentationtimer;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceActivity;
import android.preference.PreferenceScreen;

public class PrefActivity extends PreferenceActivity implements
        SharedPreferences.OnSharedPreferenceChangeListener {
    private static final String TAG = "presentationTimer";

    //private EditTextPreference m;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        addPreferencesFromResource(R.xml.pref);
        
        PreferenceScreen ps;
        Intent intent;
        
        for (int i = 1; i <= 3; i++) {
            ps = (PreferenceScreen)findPreference("_" + i + "bell");
            assert(ps != null);
            intent = new Intent(this, TimeSetActivity.class);
            intent.putExtra("kind", i);
            ps.setIntent(intent);
        }
        
        updateUi();
    }

    @Override
    public void onResume() {
        super.onResume();
        getPreferenceScreen().getSharedPreferences().registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        getPreferenceScreen().getSharedPreferences().unregisterOnSharedPreferenceChangeListener(
                this);
    }
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        updateUi();
    }

    private void updateUi() {
        // ここで summary を変更する
    }
}
