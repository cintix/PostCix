
using GLib;

public class Map<K,V> : GLib.Object {
    private K[] keys = {};
    private V[] values = {};


    public void set_key(K key, V value) {
        keys += key;
        values += value;
    }

    public V get_key(K key) {
        int index = get_index_from_key(key);
        if (index != -1) {
            return values[index];
        }
        return null;
    }

    public void remove(K key) {
        int index = get_index_from_key(key);
        if (index != -1) {

			K[] tmp_keys = {};
			V[] tmp_values = {};

			for (int i = 0; i < keys.length;i++) {
				if (key==keys[i]) {
					continue;
				}
				tmp_keys += keys[i];
				tmp_values += values[i];
			}

			keys = null;
			values = null;

			keys = tmp_keys;
			values = tmp_values;

			tmp_keys = null;
			tmp_values = null;
        }

    }


    private int get_index_from_key(K key) {
        for(int index = 0; index < keys.length; index++) {
            if (key == keys[index]) {
                return index;
            }
        }
        return -1;
    }
}

