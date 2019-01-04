
using Gtk;
using Gdk;


public class DatabaseView : Gtk.Window {

	FavoriteWindow favorite;
	PostgreSQL database;
	HostItem item;

    Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
    Grid grid = new Gtk.Grid();



	public DatabaseView(FavoriteWindow _f, PostgreSQL _p, HostItem _h) {

		this.favorite = _f;
		this.database = _p;
		this.item = _h;


		destroy.connect(this.close_and_show_favorits);
		title = "PostgreSQL connect - " + item.nickname;
		set_default_size(800,600);
		window_position = Gtk.WindowPosition.CENTER;

		favorite.hide();

	}


	public void close_and_show_favorits() {
        favorite.show_all();
		this.close;
	}

}
