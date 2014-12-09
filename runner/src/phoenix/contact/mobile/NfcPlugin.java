package phoenix.contact.mobile;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

public class NfcPlugin extends CordovaPlugin {

	public final static String READ = "read";

	public final static int NFC_RESULT_ERROR = 1;
	public final static int NFC_RESULT_OK = 0;

	private Object mutex = new Object();
	private String cardId = null;
	private String cardData = null;
	private boolean isCanceled = false;
	private int result = NFC_RESULT_ERROR;
	private String reasonIfError = null;

	@Override
	public boolean execute(String action, JSONArray data,
			CallbackContext callbackContext) throws JSONException {

		this.cordova.setActivityResultCallback(this);

		switch (action) {
		case READ:
			Activity activity = this.cordova.getActivity();
			Intent intent = new Intent(activity, NfcProcActivity.class);

			// arg0 is the password passed by javascript
			String arg0 = data.getString(0);
			if (arg0 != null) {
				intent.putExtra("password", arg0.getBytes());
			}

			// clear last data when starting a new activity to read a card
			cardId = null;
			cardData = null;
			isCanceled = false;
			result = NFC_RESULT_ERROR;
			reasonIfError = null;

			activity.startActivityForResult(intent, 1);

			sleep();

			// FIXME:
			// when disable the nfc, i can get the tips
			// "please enable the NFC first." indicating that the nfc does not
			// enable, but the user interface
			// is dead if i touch the screen too quick, because it sleep again!
			// some problem occurred here. not very often

			if (!isCanceled) {
				JSONObject jsonObj = new JSONObject();
				if (result == NfcPlugin.NFC_RESULT_OK) {
					jsonObj.put("card_id", cardId);
					jsonObj.put("card_data", cardData);
					callbackContext.success(jsonObj);
				} else {
					jsonObj.put("reason", reasonIfError);
					callbackContext.error(jsonObj);
				}
			}
			break;

		default:
			// invalid action
			return false;
		}
		return true;
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		Log.d("NfcPlugin", "result back!");
		if (requestCode == 1) {
			if (resultCode == Activity.RESULT_FIRST_USER) {
				result = intent.getIntExtra("result",
						NfcPlugin.NFC_RESULT_ERROR);
				if (result == NfcPlugin.NFC_RESULT_OK) {
					cardId = bytesToHexString(intent
							.getByteArrayExtra("card_id"));
					cardData = bytesToHexString(intent
							.getByteArrayExtra("card_data"));
				} else {
					reasonIfError = intent.getStringExtra("reason");
				}
			} else if (resultCode == Activity.RESULT_CANCELED) {
				isCanceled = true;
			}
		}
		super.onActivityResult(requestCode, resultCode, intent);
		
		wakeup();
	}

	private void sleep() {
		try {
			synchronized (mutex) {
				Log.d("NfcPlugin", "now sleep");
				mutex.wait();
			}
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	private void wakeup() {
		synchronized (mutex) {
			mutex.notify();
			Log.d("NfcPlugin", "now wake up");
		}
	}

	private String bytesToHexString(byte[] src) {
		StringBuilder stringBuilder = new StringBuilder();
		if (src == null || src.length <= 0) {
			return null;
		}
		char[] buffer = new char[2];
		for (int i = 0; i < src.length; i++) {
			buffer[0] = Character.forDigit((src[i] >>> 4) & 0x0F, 16);
			buffer[1] = Character.forDigit(src[i] & 0x0F, 16);
			stringBuilder.append(buffer);
		}
		return stringBuilder.toString();
	}

}
