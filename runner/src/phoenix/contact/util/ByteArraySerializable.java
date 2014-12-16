package phoenix.contact.util;

public interface ByteArraySerializable {

	byte[] serialize();

	void unSerialize(byte[] b);

	/**
	 * serialized size as bytes
	 * 
	 * @return the size of the instance in memory
	 */
	int size();
}
