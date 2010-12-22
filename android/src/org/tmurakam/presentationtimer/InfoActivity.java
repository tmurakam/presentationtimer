package org.tmurakam.presentationtimer;

import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;

public class InfoActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.info);

        TextView textAppName = (TextView)findViewById(R.id.TextAppName);
        textAppName.setText(R.string.app_name);

        TextView textVersion = (TextView)findViewById(R.id.TextVersion);
        String version = "?";
        try {
            String pkgname = this.getPackageName();
            PackageInfo pi = getPackageManager().getPackageInfo(pkgname, 0);
            version = pi.versionName;
        } catch (NameNotFoundException e) {
        }
        textVersion.setText(String.format("Version %s", version));
    }

    public void onClickHelp(View v) {
        String url = getResources().getString(R.string.help_url);

        Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(i);
    }
}
