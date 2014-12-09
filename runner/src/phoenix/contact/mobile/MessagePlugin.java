package phoenix.contact.mobile;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.telephony.SmsManager;
import android.util.Log;

public class MessagePlugin extends CordovaPlugin {

	private static final String SEND = "send";
	private Object mutex = new Object();

	@Override
	public boolean execute(String action, JSONArray data,
			CallbackContext callbackContext) throws JSONException {

		if (SEND.equals(action)) {
			try {
				// 手机号
				String target = data.getString(0);
				// 短信内容
				String content = data.getString(1);
				// 这里引入的是android.telephony.SmsManager
				SmsManager sms = SmsManager.getDefault();
				// 发送短信
				sms.sendTextMessage(target, null, content, null, null);

				// 封装信息返回给index.html的success(data)函数执行
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("target", target);
				jsonObj.put("content", content);
				// 执行成功结果
				callbackContext.success(jsonObj);
			} catch (JSONException e) {
				callbackContext.error("message not send");
			}
		} else if ("openActivity".equals(action)) {
			Activity act = this.cordova.getActivity();
			Intent intent = new Intent(act, NfcProcActivity.class);
			act.startActivity(intent);
		} else if ("openActivityForResult".equals(action)) {
			Activity act = this.cordova.getActivity();
			this.cordova.setActivityResultCallback(this);
			Intent intent = new Intent(act, NfcProcActivity.class);

			// the request code should be greater than 1,
			// thus the onActivityResult will be called
			// when the started activity returned
			act.startActivityForResult(intent, 1);
			
			// wait for the result
			sleep();
			
			JSONObject jsonObj = new JSONObject();
			jsonObj.put("card_id", "12345678");
			callbackContext.success(jsonObj);
			
		} else {
			// invalid action
			return false;
		}

		return true;
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		if (requestCode == 1) {
			if (resultCode == Activity.RESULT_OK) {
				Log.d("MessagePlugin", "result back!");
				wakeup();
			}
		}
		super.onActivityResult(requestCode, resultCode, intent);
	}

	private void sleep() {
		try {
			synchronized (mutex) {
				mutex.wait();
			}
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	private void wakeup() {
		synchronized (mutex) {
			mutex.notify();
		}
	}

}
