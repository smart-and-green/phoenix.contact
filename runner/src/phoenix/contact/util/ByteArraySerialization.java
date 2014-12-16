package phoenix.contact.util;

/**
 * big endian mode serialization transform between bytes and integers or floats
 * 
 * @author Administrator
 *
 */
public class ByteArraySerialization {

	public static int bytesToInt32(final byte[] src, int srcStartIndex) {
		int index = srcStartIndex;
		int intVal = (((int) src[index++] << 24) & 0xff000000)
				| (((int) src[index++] << 16) & 0x00ff0000)
				| (((int) src[index++] << 8) & 0x0000ff00)
				| (((int) src[index++]) & 0x000000ff);
		return intVal;
	}
	
	public static short bytesToInt16(final byte[] src, int srcStartIndex) {
		int index = srcStartIndex;
		short intVal = (short) ((((short) src[index++] << 8) & 0xff00)
				| (((short) src[index++]) & 0x00ff));
		return intVal;
	}

	public static int int32ToBytes(byte[] dst, int dstStartIndex, final int src) {
		dst[dstStartIndex++] = (byte) ((src >> 24) & 0xff);
		dst[dstStartIndex++] = (byte) ((src >> 16) & 0xff);
		dst[dstStartIndex++] = (byte) ((src >> 8) & 0xff);
		dst[dstStartIndex++] = (byte) (src & 0xff);
		
		// return the size of int
		return 4;
	}
	
	public static int int16ToBytes(byte[] dst, int dstStartIndex, final int src) {
		dst[dstStartIndex++] = (byte) ((src >> 8) & 0xff);
		dst[dstStartIndex++] = (byte) (src & 0xff);
		
		// return the size of short
		return 2;
	}
	
	public static float bytesToFloat(final byte[] src, int srcStartIndex) {
		int intBits = bytesToInt32(src, srcStartIndex);
		return Float.intBitsToFloat(intBits);
	}
	
	public static int floatToBytes(byte[] dst, int dstStartIndex, final float src) {
		int val = Float.floatToIntBits(src);
		
		// return the size of float (which is equal to int)
		return int32ToBytes(dst, dstStartIndex, val);
	}
	
}
