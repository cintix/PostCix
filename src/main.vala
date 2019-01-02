
using Gtk;
using Gdk;


public class Application : Gtk.Window {
	public Application() {

		destroy.connect(Gtk.main_quit);
		title = "PostgreSQL Client";
		set_default_size(720,560);
		window_position = Gtk.WindowPosition.CENTER;
		Grid layoutGrid = new Gtk.Grid();

		Grid grid = new Gtk.Grid();
		grid.set_row_homogeneous(false);
		grid.set_column_homogeneous(false);

		//grid.set_hexpand(false);
		//grid.set_size_request(400,400);

		Pixbuf pixbuf = new Gdk.Pixbuf.from_file(".postico/img/logo.png");
		pixbuf = pixbuf.scale_simple(300, 300, Gdk.InterpType.BILINEAR);

		Image logo = new Gtk.Image();
		logo.set_from_pixbuf(pixbuf);
	//	logo.set_from_file(".postico/img/logo.png");

		layoutGrid.attach(logo, 0, 1, 1, 1);


		Label label = new Gtk.Label("PostgreSQL Client");
		layoutGrid.attach(label, 0, 0, 1, 1);

		for (int index = 0; index < 15; index++) {
			HostItem item = new HostItem();
			grid.attach(item, 1, index, 1,1);
		}


		ScrolledWindow scroll = new Gtk.ScrolledWindow(null,null);
		scroll.min_content_height = 380;
		scroll.min_content_width = 352;
		scroll.hexpand = true;
		scroll.vexpand = true;
		//scroll.shadow_type = Gtk.ShadowType.IN;
		scroll.border_width = 10;
		scroll.hscrollbar_policy = Gtk.PolicyType.ALWAYS;
		scroll.add(grid);
		scroll.show();

		layoutGrid.attach(scroll, 2,1,1,1);

		var file = File.new_for_path (".postico");

		if (!file.query_exists()) {
			file.make_directory();
		}

        stdout.printf ("%s\n", file.get_path());

		string cssString = ".scrollbar.vertical slider, scrollbar.vertical slider {
								min-height: 150px;
								min-width: 10px;
				      }";

        Gtk.CssProvider css_provider = new Gtk.CssProvider ();
        css_provider.load_from_data(cssString, cssString.length);
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);



//		grid.show();
		layoutGrid.show();

		add(layoutGrid);
	}
}

int main (string[] args) {
    Gtk.init (ref args);

    Application postIco = new Application ();
    postIco.show_all();

    Gtk.main ();
    return 0;
}
