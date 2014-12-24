package phoenix.contact.mobile;

import org.apache.cordova.DroidGap;

import android.os.Bundle;

public class MainActivity extends DroidGap
{
	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		//super.loadUrl("file:///android_asset/www/login.html");
		super.loadUrl("http://10.141.90.240:8080/index");
	}
}

