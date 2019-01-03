using Gtk;
using Gdk;


public class Setting : Object {

	private string settingsFile;

	public Setting(string file) {
		this.settingsFile = file;
	}


	public bool write_host_item (HostItem item, bool keep_old_data) {

		try {
			File file = File.new_for_path(this.settingsFile);
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


}
