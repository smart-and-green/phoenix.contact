package phoenix.contact.util;

/**
 * a byte Serializable Date type, all members are serialized to byte stream
 * 
 * @author Administrator
 *
 */
public class SerializableDate implements ByteArraySerializable {
	public short year;
	public byte month;
	public byte day;
	public byte hour;
	public byte minute;
	public byte second;

	public SerializableDate() {
		year = 0;
		month = 0;
		day = 0;
		hour = 0;
		minute = 0;
		second = 0;
	}
	
	@Override
	public byte[] serialize() {
		byte[] ret = new byte[size()];
		ByteArraySerialization.int16ToBytes(ret, 0, year);
		ret[2] = month;
		ret[3] = day;
		ret[4] = hour;
		ret[5] = minute;
		ret[6] = second;
		return ret;
	}

	@Override
	public void unSerialize(byte[] b) {
		year = ByteArraySerialization.bytesToInt16(b, 0);
		month = b[2];
		day = b[3];
		hour = b[4];
		minute = b[5];
		second = b[6];
	}

	@Override
	public int size() {
		return 7;
	}

}
