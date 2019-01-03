
using Gtk;
using Gdk;


public class DatabaseView : Gtk.Window {

    Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
    Grid grid = new Gtk.Grid();

	public DatabaseView() {

		destroy.connect(Gtk.main_quit);
		title = "PostgreSQL Client";
		set_default_size(800,600);
		window_position = Gtk.WindowPosition.CENTER;
	}

}
