package phoenix.contact.exercise;

import phoenix.contact.util.ByteArraySerializable;
import phoenix.contact.util.ByteArraySerialization;
import phoenix.contact.util.Copier;
import phoenix.contact.util.SerializableDate;

public class ExerciseRecord implements ByteArraySerializable {

	public SerializableDate startTimeStamp;
	public SerializableDate endTimeStamp;
	public float energy;
	public float power;

	public ExerciseRecord() {
		startTimeStamp = new SerializableDate();
		endTimeStamp = new SerializableDate();
		energy = 0;
		power = 0;
	}
	
	@Override
	public byte[] serialize() {
		byte[] ret = new byte[size()];
		int size = 0;
		size += Copier.copy(ret, size, startTimeStamp.serialize(), 0, startTimeStamp.size());
		size += Copier.copy(ret, size, endTimeStamp.serialize(), 0, endTimeStamp.size());
		size += ByteArraySerialization.floatToBytes(ret, size, energy);
		size += ByteArraySerialization.floatToBytes(ret, size, power);
		return ret;
	}

	@Override
	public void unSerialize(byte[] b) {
		int size = 0;
		byte[] startTimeBytes = new byte[startTimeStamp.size()];
		byte[] endTimeBytes = new byte[endTimeStamp.size()];
		size += Copier.copy(startTimeBytes, 0, b, size, startTimeStamp.size());
		size += Copier.copy(endTimeBytes, 0, b, size, endTimeStamp.size());
		startTimeStamp.unSerialize(startTimeBytes);
		endTimeStamp.unSerialize(endTimeBytes);
		energy = ByteArraySerialization.bytesToFloat(b, size);
		size += 4;
		power = ByteArraySerialization.bytesToFloat(b, size);
		size += 4;
	}

	@Override
	public int size() {
		int s = 0;
		s += startTimeStamp.size();
		s += endTimeStamp.size();
		s += 4;
		s += 4;
		return s;
	}

}
