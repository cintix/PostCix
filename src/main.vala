
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


		Image logo = load_image(".postcix/img/baby.png", 300,250);

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
            int index  = row_count(grid,1);

            HostItem item = new HostItem();
			item.button_press_event.connect((event) => {
				if (event.type == EventType.BUTTON_PRESS && event.button == 3) {
					Gtk.Menu menu = new Gtk.Menu ();
					Gtk.MenuItem menu_item = new Gtk.MenuItem.with_label ("Delete");
					menu.attach_to_widget (item, null);
					menu.add (menu_item);
					menu.show_all ();
					menu.popup_at_widget(item, Gdk.Gravity.CENTER, Gdk.Gravity.CENTER, null);

					menu_item.button_press_event.connect((event) => {
						if (event.type == EventType.BUTTON_PRESS && event.button != 3) {
							grid.remove(item);
							grid.show_all();

							Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
   						    int results = 0;
							while(grid.get_child_at(1,results) != null) {
								HostItem _item = (HostItem) grid.get_child_at(1,results);
								stdout.printf("Do you think this work : item %s\n", _item.nickname);
								results++;
							}
						}
						return false;
					});

				}
				return false;
			});

            grid.attach(item, 1, index,1,1);
			grid.show_all();
        });

		var file = File.new_for_path (".postcix");

		if (!file.query_exists()) {
			try {
				file.make_directory();
			} catch (Error e) {
				return;
			}
		}

		string css = ".scrollbar.vertical slider, scrollbar.vertical slider {
								min-height: 150px;
								min-width: 10px;
				      }";

		apply_custom_css(css);


		layoutGrid.show();
		add(layoutGrid);
	}



	/*
	 * Load image-file into buffer resize and convert to  image
	 */
	private Gtk.Image load_image(string file, int width, int height) {
		Pixbuf pixbuf;

		try {
		  pixbuf = new Gdk.Pixbuf.from_file(file);
		  pixbuf = pixbuf.scale_simple(width, height, Gdk.InterpType.BILINEAR);
		 } catch (Error e) {
		 	return null;
		 }

		Image image = new Gtk.Image();
		image.set_from_pixbuf(pixbuf);
		return image;
	}


	/*
	 * Apply Css styles to document
	 */
	private void apply_custom_css(string cssString) {
		try {
		    Gtk.CssProvider css_provider = new Gtk.CssProvider ();
		    css_provider.load_from_data(cssString, cssString.length);
		    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		} catch (Error e) {
			return;
		}
		return;
	}


    // get row count from grid based on a column
	private int row_count(Gtk.Grid grid, int column) {
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
