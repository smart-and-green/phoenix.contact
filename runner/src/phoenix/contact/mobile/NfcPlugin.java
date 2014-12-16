package phoenix.contact.mobile;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import phoenix.contact.exercise.ExerciseRecord;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;

public class NfcPlugin extends CordovaPlugin {

	public final static String READ = "read";
	public final static String WRITE = "write";
	public final static int READ_REQUEST = 1;
	public final static int WRITE_REQUEST = 2;

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
		
		ExerciseRecord er = new ExerciseRecord();
		er.energy = -1.000067f;
		er.startTimeStamp.year = 2014;
		er.startTimeStamp.month = 12;
		er.startTimeStamp.day = 2;
		er.startTimeStamp.hour = 15;
		byte[] b = er.serialize();
		ExerciseRecord er2 = new ExerciseRecord();
		er2.unSerialize(b);
		Log.d("MyTest", "energy=" + er2.energy);
		Log.d("MyTest", "year=" + er2.startTimeStamp.year);
		Log.d("MyTest", "month=" + er2.startTimeStamp.month);
		Log.d("MyTest", "day=" + er2.startTimeStamp.day);
		Log.d("MyTest", "hour=" + er2.startTimeStamp.hour);
		Log.d("MyTest", "minute=" + er2.startTimeStamp.minute);
		Log.d("MyTest", "second=" + er2.startTimeStamp.second);

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

		switch (action) {
		case READ:
			Log.d("NfcPlugin", "read a tag");
			intent.putExtra("command", "read");
			activity.startActivityForResult(intent, READ_REQUEST);

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
			break;

		case WRITE:
			Log.d("NfcPlugin", "write tag command");
			intent.putExtra("command", "write");
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
			activity.startActivityForResult(intent, WRITE_REQUEST);
			sleep();

			if (!isCanceled) {
				JSONObject jsonObj = new JSONObject();
				if (result == NfcPlugin.NFC_RESULT_OK) {
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
		if (requestCode == READ_REQUEST) {
			if (resultCode == Activity.RESULT_FIRST_USER) {
				result = intent.getIntExtra("result",
						NfcPlugin.NFC_RESULT_ERROR);
				if (result == NfcPlugin.NFC_RESULT_OK) {
					cardData = intent.getByteArrayExtra("cardData");
				} else {
					reasonIfError = intent.getStringExtra("reason");
				}
			} else if (resultCode == Activity.RESULT_CANCELED) {
				isCanceled = true;
			}
		} else if (requestCode == WRITE_REQUEST) {
			if (resultCode == Activity.RESULT_FIRST_USER) {
				result = intent.getIntExtra("result",
						NfcPlugin.NFC_RESULT_ERROR);
				if (result == NfcPlugin.NFC_RESULT_OK) {

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
