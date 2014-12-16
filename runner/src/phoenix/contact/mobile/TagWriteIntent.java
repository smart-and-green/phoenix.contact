package phoenix.contact.mobile;

import java.io.Serializable;
import java.util.LinkedList;

public class TagWriteIntent implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4394163761991677696L;

	public static class WriteStruct implements Serializable {
		/**
		 * 
		 */
		private static final long serialVersionUID = 2961118981489604872L;
		public int blockIndex;
		public byte[] data;
		
		public WriteStruct(int blockIndex, byte[] data) {
			this.blockIndex = blockIndex;
			this.data = data;
		}
	}
	
	// the write command list, the length of blocksList and the dataList must be
	// the same
	public LinkedList<WriteStruct> writeIntentList;
	
	public TagWriteIntent() {
		writeIntentList = new LinkedList<WriteStruct>();
	}
	
	public void addData(int blockIndex, byte[] data) {
		writeIntentList.add(new WriteStruct(blockIndex, data));
	}
	
}
