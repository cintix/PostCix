using Gtk;
using Gdk;


public class Setting : Object {

	private File file;

    /*
     *  Constructor with file
     */
	public Setting(File _file) {
		this.file = _file;
	}


    /*
     *  Write a hostitem to the settings file
     */
	public bool write_host_item (HostItem? item, bool keep_old_data) {
        if (item == null) return false;
		try {

			FileIOStream ios;
			FileOutputStream os;
			DataOutputStream dos;

			if (file.query_exists() && keep_old_data) {
				os = file.append_to(FileCreateFlags.PRIVATE);
			} else if (file.query_exists() && !keep_old_data) {
				file.delete();
				ios = file.create_readwrite (FileCreateFlags.PRIVATE);
				os = ios.output_stream as FileOutputStream;
			} else {
				ios = file.create_readwrite (FileCreateFlags.PRIVATE);
				os = ios.output_stream as FileOutputStream;
			}

			dos = new DataOutputStream (os);
			dos.put_string(item.nickname + "|" + item.host + "|" + item.port.to_string() + "|" + item.username + "|" + item.password + "|" + item.database_name +"\n");

			return true;
		} catch (Error e) {
		}

		return false;
	}

    /*
     * read the list of hostitems from the settings file
     */
    public HostItem[] read_host_items() {

        HostItem[] items = {};
        if (file.query_exists()) {
            stdout.printf("found settings\n");
            try {
                DataInputStream input_stream = new DataInputStream(file.read());
                string line;
                stdout.printf("reading lines\n");
                while ((line = input_stream.read_line (null)) != null) {
                    stdout.printf("line : %s\n", line);
                    if (line != null && line.length > 1) {
                        string[] host_info = line.split("|");
                        string nickname = host_info[0];
                        string host = host_info[1];
                        int port = int.parse(host_info[2]);
                        string username = host_info[3];
                        string password = host_info[4];
                        string database_name = host_info[5];

                        stdout.printf("nick : %s\n", nickname);
                        HostItem hitem = new HostItem.with_values(nickname,host,port,username,password,database_name);
                        stdout.printf("Item %s\n", hitem.nickname);
                        items += hitem;
                    }

                }

            } catch(Error e) {}
        }
        return items;
    }

}
