package org.tmurakam.presentationtimer;

public class PrefActivity extends PreferenceActivity implements
        SharedPreferences.OnSharedPreferenceChangeListener {
    private static final String TAG = "presentationTimer";

    //private EditTextPreference m;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        addPreferencesFromResource(R.xml.pref);

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
