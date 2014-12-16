package phoenix.contact.util;

public class Copier {
	public static int copy(byte[] dst, int dstStartIndex, final byte[] src, int srcStartIndex, int size) {
		int copiedSize = size;
		while (size-- != 0) {
			dst[dstStartIndex++] = src[srcStartIndex++];
		}
		return copiedSize;
	}
}	
