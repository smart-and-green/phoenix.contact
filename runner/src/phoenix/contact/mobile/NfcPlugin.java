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
	public final static String WRITE = "write";
	public final static String READ_THEN_WRITE = "readThenWrite";
	public final static int NO_REQUEST = 0x00;
	public final static int READ_REQUEST = 0x01;
	public final static int WRITE_REQUEST = 0x02;

	public final static int NFC_RESULT_ERROR = 1;
	public final static int NFC_RESULT_OK = 0;

	private Object mutex = new Object();
	private byte[] cardData = null;
	private boolean isCanceled = false;
	private int result = NFC_RESULT_ERROR;
	private String reasonIfError = null;

	@Override
	public boolean execute(String action, JSONArray data,
			CallbackContext callbackContext) throws JSONException {
		
		this.cordova.setActivityResultCallback(this);
		Activity activity = this.cordova.getActivity();
		Intent intent = new Intent(activity, NfcProcActivity.class);

		// arg0 is the password passed by javascript

		if (!data.isNull(0)) {
			JSONArray arg0 = data.getJSONArray(0);
			Log.d("NfcPlugin", "arg0=" + arg0.toString());
			byte[] password = new byte[arg0.length()];
			for (int i = 0; i < password.length; ++i) {
				password[i] = (byte) arg0.getInt(i);
			}
			intent.putExtra("password", password);
		}

		// clear last data when starting a new activity to read a card
		cardData = null;
		isCanceled = false;
		result = NFC_RESULT_ERROR;
		reasonIfError = null;
		int requestCode = NO_REQUEST;

		boolean actionMatched = false;
		if (action.equals(READ) || action.equals(READ_THEN_WRITE)) {
			Log.d("NfcPlugin", "read a tag");
			actionMatched = true;
			intent.putExtra("command", "read");
			requestCode |= READ_REQUEST;

			// FIXME:
			// when disable the nfc, i can get the tips
			// "please enable the NFC first." indicating that the nfc does not
			// enable, but the user interface
			// is dead if i touch the screen too quick, because it sleep again!
			// some problem occurred here. not very often
		}
		if (action.equals(WRITE) || action.equals(READ_THEN_WRITE)) {
			Log.d("NfcPlugin", "write tag command");
			actionMatched = true;
			intent.putExtra("command", "write");
			requestCode |= WRITE_REQUEST;
			
			TagWriteIntent tagWriteIntent = new TagWriteIntent();
			JSONArray writeIntentArray = data.getJSONArray(1);
			for (int i = 0; i < writeIntentArray.length(); ++i) {
				JSONObject writeIntentObj = writeIntentArray.getJSONObject(i);
				JSONArray dataArrayToWrite = writeIntentObj
						.getJSONArray("data");
				byte[] byteArrayToWrite = new byte[16];
				for (int j = 0; j < dataArrayToWrite.length(); ++j) {
					byteArrayToWrite[j] = (byte) dataArrayToWrite.getInt(j);
				}
				tagWriteIntent.addData(writeIntentObj.getInt("blockIndex"),
						byteArrayToWrite);
			}
			intent.putExtra("tagWriteIntent", tagWriteIntent);
		}
		if (!actionMatched) {
			return false;
		}
		
		intent.putExtra("command", requestCode);
		activity.startActivityForResult(intent, requestCode);
		
		// wait for activity result back
		sleep();
		
		if (!isCanceled) {
			JSONObject jsonObj = new JSONObject();
			if (result == NfcPlugin.NFC_RESULT_OK) {
				JSONArray cardDataArray = new JSONArray();
				for (int i = 0; i < cardData.length; ++i) {
					// bit-and operation make cardData as an unsigned integer
					cardDataArray.put(((int) cardData[i]) & 0xFF);
				}
				JSONArray cardIdArray = new JSONArray();
				for (int i = 0; i < 16; ++i) {
					cardIdArray.put(((int) cardData[i]) & 0xFF);
				}
				jsonObj.put("cardData", cardDataArray);
				jsonObj.put("cardId", cardIdArray);
				callbackContext.success(jsonObj);
			} else {
				jsonObj.put("reason", reasonIfError);
				callbackContext.error(jsonObj);
			}
		}

		return true;
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		Log.d("NfcPlugin", "result back!");
		result = intent.getIntExtra("result", NfcPlugin.NFC_RESULT_ERROR);
		if (resultCode == Activity.RESULT_CANCELED) {
			isCanceled = true;
		} else if (resultCode == Activity.RESULT_FIRST_USER) {
			if ((requestCode & READ_REQUEST) != 0) {
				if (result == NfcPlugin.NFC_RESULT_OK) {
					cardData = intent.getByteArrayExtra("cardData");
				} else {
					reasonIfError = intent.getStringExtra("reason");
				}
			}
			if ((requestCode & WRITE_REQUEST) != 0) {
				if (result != NfcPlugin.NFC_RESULT_OK) {
					// append error information if write error occurred
					reasonIfError += "\n";
					reasonIfError += intent.getStringExtra("reason");
				}
			}
		} else {
			Log.d("NfcPlugin", "invalid result code");
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

	@SuppressWarnings("unused")
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
