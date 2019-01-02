
using Gtk;
using Gdk;


public class Application : Gtk.Window {
    Grid grid = new Gtk.Grid();

	public Application() {

		destroy.connect(Gtk.main_quit);
		title = "PostgreSQL Client";
		set_default_size(700,420);
		window_position = Gtk.WindowPosition.CENTER;

		Grid layoutGrid = new Gtk.Grid();

		layoutGrid.set_column_spacing(4);
		layoutGrid.set_row_spacing(4);

		layoutGrid.set_row_homogeneous(false);
		layoutGrid.set_column_homogeneous(false);

		grid.set_row_homogeneous(false);
		grid.set_column_homogeneous(false);

		//grid.set_hexpand(false);
		//grid.set_size_request(400,400);

		Pixbuf pixbuf;
		try {
		  pixbuf = new Gdk.Pixbuf.from_file(".postcix/img/baby.png");
		  pixbuf = pixbuf.scale_simple(300, 250, Gdk.InterpType.BILINEAR);
		 } catch (Error e) {
		 	return ;
		 }

		Image logo = new Gtk.Image();
		logo.set_from_pixbuf(pixbuf);
	//	logo.set_from_file(".postico/img/logo.png");
        Box logoBox = new Gtk.Box(Gtk.Orientation.VERTICAL,10);
        logoBox.margin_left = 15;
        logoBox.margin_top = 25;
        logoBox.add(logo);
		layoutGrid.attach(logoBox, 0, 0, 1, 1);


		Label label = new Gtk.Label("PostgreSQL Client");
		layoutGrid.attach(label, 0, 1, 1, 1);

        Box box = new Gtk.Box(Gtk.Orientation.VERTICAL,10);
        box.margin_left = 15;
        box.margin_top = 25;

		Button favorites = new Gtk.Button.with_label("New Favorite");
        favorites.set_size_request(150, 40);
        box.add(favorites);
		layoutGrid.attach(box, 0, 2, 1, 1);

        Box horizontal_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1);
		horizontal_box.set_size_request(250,4);
		layoutGrid.attach(horizontal_box, 0,3,1,1);

		/*for (int index = 0; index < 5; index++) {
			HostItem item = new HostItem();
			grid.attach(item, 1, index, 1,1);
		}*/

		ScrolledWindow scroll = new Gtk.ScrolledWindow(null,null);
		scroll.min_content_height = 380;
		scroll.min_content_width = 302;
		scroll.hexpand = true;
		scroll.vexpand = true;
		scroll.border_width = 10;
		scroll.hscrollbar_policy = Gtk.PolicyType.ALWAYS;
		scroll.add(grid);
		scroll.show();

		layoutGrid.attach(scroll, 2,0,1,4);


        favorites.clicked.connect(()=> {
            int index  = rowCount(grid,1);
            grid.attach(new HostItem(), 1, index,1,1);
			grid.show_all();
            stdout.printf("Adding new host\n");
            stdout.printf("children in list ? %d\n", rowCount(grid, 1));
        });

		var file = File.new_for_path (".postcix");

		if (!file.query_exists()) {
			try {
				file.make_directory();
			} catch (Error e) {
				return;
			}
		}

		string cssString = ".scrollbar.vertical slider, scrollbar.vertical slider {
								min-height: 150px;
								min-width: 10px;
				      }";

		try {
		    Gtk.CssProvider css_provider = new Gtk.CssProvider ();
		    css_provider.load_from_data(cssString, cssString.length);
		    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		} catch (Error e) {
			return;
		}



//		grid.show();
		layoutGrid.show();

		add(layoutGrid);
	}


    // get row count from grid based on a column
	private int rowCount(Gtk.Grid grid, int column) {
        int results = 0;
        while(grid.get_child_at(column,results) != null) {
            results++;
        }
        return results;
	}

}

int main (string[] args) {
    Gtk.init (ref args);

    Application postIco = new Application ();
    postIco.show_all();

    Gtk.main ();
    return 0;
}
