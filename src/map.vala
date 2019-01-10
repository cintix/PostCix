
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


int main (string[] args) {

	Map<int,string> my_map = new Map<int,string>();

	my_map.set_key(2610, "Rødover");
	my_map.set_key(2620, "Albertslund");
	my_map.set_key(2630, "Høje Tåstrup");
	my_map.set_key(2600, "Glostrup");

	int[] zip_codes = {2600,2610,2620,2630};


	foreach (int post_number in zip_codes) {
		string city = my_map.get_key(post_number);
		if (city == null) continue;
		stdout.printf("Byen %s har post nummeret %d\n", city , post_number);
	}

	my_map.remove(2610);
	stdout.printf("Removing Rødover,,,\n\n");
	foreach (int post_number in zip_codes) {
		string city = my_map.get_key(post_number);
		if (city == null) continue;
		stdout.printf("Byen %s har post nummeret %d\n", city, post_number);
	}


    return 0;
}
