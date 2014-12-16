package phoenix.contact.mobile;

import java.io.IOException;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentFilter.MalformedMimeTypeException;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.MifareClassic;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

public class NfcProcActivity extends Activity {

	private NfcAdapter nfcAdapter;
	private PendingIntent pendingIntent;
	private IntentFilter[] intentFilters;
	private String[][] techLists;
	
	private byte[] password;
	private String command;
	private TagWriteIntent tagWriteIntent;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_nfc_proc);
		
		TextView tips = (TextView) findViewById(R.id.proc_tips);

		pendingIntent = PendingIntent.getActivity(this, 0, new Intent(this,
				getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), 0);
		IntentFilter ndef = new IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED);
		try {
			ndef.addDataType("*/*");
		} catch (MalformedMimeTypeException e) {
			throw new RuntimeException("fail", e);
		}
		intentFilters = new IntentFilter[] { ndef };

		techLists = new String[][] { new String[] { MifareClassic.class
				.getName() } };

		nfcAdapter = NfcAdapter.getDefaultAdapter(this);
		if (nfcAdapter == null) {
			// NFC not available on this device
			Log.d("nfc push", "nfc unavailable");

			Intent result_intent = new Intent();
			result_intent.putExtra("result", NfcPlugin.NFC_RESULT_ERROR);
			result_intent.putExtra("reason", "NFC unavailable on this device.");
			setResult(Activity.RESULT_FIRST_USER, result_intent);
			finish();
		}

		if (!nfcAdapter.isEnabled()) {
			Intent result_intent = new Intent();
			result_intent.putExtra("result", NfcPlugin.NFC_RESULT_ERROR);
			result_intent.putExtra("reason", "please enable the NFC first.");
			setResult(Activity.RESULT_FIRST_USER, result_intent);
			finish();
		}

		password = getIntent().getByteArrayExtra("password");
		command = getIntent().getStringExtra("command");
		tagWriteIntent = (TagWriteIntent) getIntent().getSerializableExtra("tagWriteIntent");
		
		tips.setText(command);
	}

	@Override
	protected void onResume() {
		super.onResume();

		nfcAdapter.enableForegroundDispatch(this, pendingIntent, intentFilters,
				techLists);
	}

	@Override
	public void onNewIntent(Intent intent) {
		Log.i("Foreground dispatch", "Discovered tag with intent: " + intent);

		if (NfcAdapter.ACTION_TECH_DISCOVERED.equals(intent.getAction())) {
			procNewTagIntent(intent, password, command);
		}
	}

	@Override
	public void onPause() {
		super.onPause();
		nfcAdapter.disableForegroundDispatch(this);
	}

	private void procNewTagIntent(Intent intent, byte[] password,
			final String command) {
		// get tag from the intent
		Tag tagFromIntent = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);

		// get MifareClassic card
		MifareClassic mfc = MifareClassic.get(tagFromIntent);
		try {
			mfc.connect();
			Intent result_intent = new Intent();
			if (command.equalsIgnoreCase("read")) {
				Log.d("NfcProc", "command=" + command);
				byte[] cardData = readMifareClassic(mfc, password);
				result_intent.putExtra("cardData", cardData);
			} else if (command.equalsIgnoreCase("write")) {
				Log.d("NfcProc", "command=" + command);
				for (TagWriteIntent.WriteStruct ws : tagWriteIntent.writeIntentList) {
					writeMifareClassicBlock(mfc, password, ws.blockIndex, ws.data);
				}
			}
			result_intent.putExtra("result", NfcPlugin.NFC_RESULT_OK);
			setResult(Activity.RESULT_FIRST_USER, result_intent);
			mfc.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		// close this activity and return
		finish();
	}

	private byte[] readMifareClassic(MifareClassic mfc, byte[] password)
			throws IOException {
		byte[] cardData = new byte[mfc.getSize()];
		int dataIndex = 0;

		int blockCount = mfc.getBlockCount();
		for (int i = 0; i < blockCount; i++) {
			byte[] blockData = readMifareClassicBlock(mfc, password, i);
			if (blockData != null) {
				for (int j = 0; j < 16; ++j) {
					cardData[dataIndex++] = blockData[j];
				}
			} else {
				dataIndex += 16;
			}
		}

		byte[] cardId = new byte[16];
		for (int i = 0; i < 16; ++i) {
			cardId[i] = cardData[i];
		}
		return cardData;
	}

	private byte[] readMifareClassicBlock(MifareClassic mfc, byte[] password,
			int blockIndex) throws IOException {
		byte[] ret = null;
		if (blockIndex >= 0 && blockIndex < mfc.getBlockCount()) {
			int sectorIndex = mfc.blockToSector(blockIndex);
			Log.d("NfcProc", "sector=" + sectorIndex + "  block=" + blockIndex);
			// Authenticate a sector with key A.
			if (password == null
					|| password.length != MifareClassic.KEY_DEFAULT.length) {
				password = MifareClassic.KEY_DEFAULT;
			}
			boolean auth = mfc.authenticateSectorWithKeyA(sectorIndex, password);
			if (auth) {
				ret = mfc.readBlock(blockIndex);
			}
		}
		return ret;
	}

	private void writeMifareClassicBlock(MifareClassic mfc, byte[] password,
			int blockIndex, byte[] data) throws IOException {
		if (blockIndex >= 0 && blockIndex < mfc.getBlockCount()) {
			int sectorIndex = mfc.blockToSector(blockIndex);
			Log.d("NfcProc", "sector=" + sectorIndex + "  block=" + blockIndex);
			// Authenticate a sector with key A.
			if (password == null
					|| password.length != MifareClassic.KEY_DEFAULT.length) {
				password = MifareClassic.KEY_DEFAULT;
			}
			boolean auth = mfc.authenticateSectorWithKeyA(sectorIndex, password);
			if (auth) {
				mfc.writeBlock(blockIndex, data);
				Log.d("NfcProc", "blockIndex=" + blockIndex + " writen!");
			} else {
				Log.d("NfcProc", "authentication fail");
			}
		}
	}

}
