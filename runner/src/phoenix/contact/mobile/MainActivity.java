package phoenix.contact.mobile;

import org.apache.cordova.DroidGap;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;

public class MainActivity extends DroidGap {
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// super.loadUrl("file:///android_asset/www/login.html");
		super.loadUrl("http://10.141.90.240:8080/index");
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
			moveTaskToBack(false);
		}
		return false;
	}
}
