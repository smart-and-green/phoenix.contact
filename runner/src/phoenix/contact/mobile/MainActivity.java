package phoenix.contact.mobile;

import org.apache.cordova.CordovaActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

public class MainActivity extends CordovaActivity {
	
	private long timeStamp = 0;
	private int keyCount = 0;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// super.loadUrl("file:///android_asset/www/login.html");
		super.loadUrl("http://10.141.90.240:8080/index");
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {	
		int keyCode = event.getKeyCode();
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			
			// 这里的按键处理有问题，每次都会当成有两次按键，所以用一个计数器
			// 当计数达到4时，认为按了两次
			++keyCount;
			
			long currentMillis = System.currentTimeMillis();
			if (keyCount >= 2) {
				keyCount = 0;
				if (currentMillis - timeStamp < 1000) {
					finish();
					Toast.makeText(this, "bye!", Toast.LENGTH_SHORT).show();
				} else {
					timeStamp = currentMillis;
					Toast.makeText(this, "press one more time to close the application", Toast.LENGTH_SHORT).show();
				}
			}
			
			Log.d("MainActivity", timeStamp + "");
			return true;
		}
		return super.dispatchKeyEvent(event);
	}
}
