

public class IOHandler: Object {

	  /*
     *  Write file
     */
	public static bool write_file (File file, string data) {
		try {

			FileIOStream ios;
			FileOutputStream os;
			DataOutputStream dos;

			if (file.query_exists()) {
				file.delete();
			}

			ios = file.create_readwrite (FileCreateFlags.PRIVATE);
			os = ios.output_stream as FileOutputStream;

			dos = new DataOutputStream (os);
			dos.put_string(data);

			return true;
		} catch (Error e) {
		}

		return false;
	}

    /*
     * read file
     */
    public static string read_file(File file) {
		string data = "";
        if (file.query_exists()) {
            try {
                DataInputStream input_stream = new DataInputStream(file.read());
                string line;
                while ((line = input_stream.read_line (null)) != null) {
					data += line + "\n";
                }

            } catch(Error e) {}
        }
        return data;
    }


}
