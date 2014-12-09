package phoenix.contact.mobile;

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

public class NfcProcActivity extends Activity {

	private NfcAdapter nfcAdapter;
	private PendingIntent pendingIntent;
	private IntentFilter[] intentFilters;
	private String[][] techLists;
	private byte[] password;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_nfc_proc);

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
		// password = null;
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
			procIntent(intent);
		}
	}

	@Override
	public void onPause() {
		super.onPause();
		nfcAdapter.disableForegroundDispatch(this);
	}

	private void procIntent(Intent intent) {
		// get tag from the intent
		Tag tagFromIntent = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);

		// get MifareClassic card
		MifareClassic mfc = MifareClassic.get(tagFromIntent);
		try {
			// Enable I/O operations to the tag from this TagTechnology
			// object.
			mfc.connect();

			byte[] cardData = new byte[mfc.getSize()];
			int dataIndex = 0;

			int sectorCount = mfc.getSectorCount();
			for (int i = 0; i < sectorCount; i++) {

				// Authenticate a sector with key A.
				if (password == null
						|| password.length != MifareClassic.KEY_DEFAULT.length) {
					password = MifareClassic.KEY_DEFAULT;
				}
				boolean auth = mfc.authenticateSectorWithKeyA(i, password);
				if (auth) {

					// read each block in this authed sector
					for (int j = 0; j < mfc.getBlockCountInSector(i); ++j) {
						// get this block
						byte[] block = mfc.readBlock(i
								* mfc.getBlockCountInSector(i) + j);

						// copy this block
						for (int k = 0; k < block.length; ++k) {
							cardData[dataIndex++] = block[k];
						}
					}
				} else {

					// if this sector is unable to auth,
					// skip the bytes of the whole sector
					// 16 bytes per sector
					dataIndex += mfc.getBlockCountInSector(i) * 16;
					Log.d("NfcActivity", "" + mfc.getBlockCountInSector(i));
				}
			}
			mfc.close();

			byte[] cardId = new byte[16];
			for (int i = 0; i < 16; ++i) {
				cardId[i] = cardData[i];
			}
			Intent result_intent = new Intent();
			result_intent.putExtra("result", NfcPlugin.NFC_RESULT_OK);
			result_intent.putExtra("card_id", cardId);
			result_intent.putExtra("card_data", cardData);
			setResult(Activity.RESULT_FIRST_USER, result_intent);
			finish();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
