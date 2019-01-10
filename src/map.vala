
using GLib;

public class Map<K,V> : GLib.Object {
    private K[] keys;
    private V[] values;


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
