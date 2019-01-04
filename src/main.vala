
using Gtk;
using Gdk;


public class Application : Gtk.Window {

    Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
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
        logoBox.margin_start = 15;
        logoBox.margin_top = 25;
        logoBox.add(logo);
		layoutGrid.attach(logoBox, 0, 0, 1, 1);


		Label label = new Gtk.Label("PostgreSQL Client");
		layoutGrid.attach(label, 0, 1, 1, 1);

        Box box = new Gtk.Box(Gtk.Orientation.VERTICAL,10);
        box.margin_start = 15;
        box.margin_top = 25;

		Button favorites = new Gtk.Button.with_label("New Favorite");
        favorites.set_size_request(150, 40);
        box.add(favorites);
		layoutGrid.attach(box, 0, 2, 1, 1);

        Box horizontal_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1);
		horizontal_box.set_size_request(250,4);
		layoutGrid.attach(horizontal_box, 0,3,1,1);

        stdout.printf("Loading settings\n");
        int item_index = 0;

        foreach (HostItem hi in settings.read_host_items()) {

            hi.editOrDone.clicked.connect(() => {
			    int results = 0;
			    bool is_first_host = false;

				while(grid.get_child_at(1,results) != null) {
					HostItem _item = (HostItem) grid.get_child_at(1,results);
					settings.write_host_item(_item, is_first_host);

					if (!is_first_host) {
						is_first_host = !is_first_host;
					}

					results++;
				}
            });

			hi.button_press_event.connect((event) => {
				if (event.type == EventType.BUTTON_PRESS && event.button == 3) {
					Gtk.Menu menu = new Gtk.Menu ();
					Gtk.MenuItem menu_item = new Gtk.MenuItem.with_label ("Delete");
					menu.attach_to_widget (hi, null);
					menu.add (menu_item);
					menu.show_all ();
					menu.popup_at_widget(hi, Gdk.Gravity.CENTER, Gdk.Gravity.CENTER, null);

					menu_item.button_press_event.connect((event) => {
						if (event.type == EventType.BUTTON_PRESS && event.button != 3) {

							int host_item_index = find_index_of_item(grid, hi, 1);
							stdout.printf("host item %s have index %d\n", hi.nickname, host_item_index);

							if (host_item_index != -1) {
								grid.remove_row(host_item_index);
							}

							grid.show_all();

   						    int results = 0;
   						    bool is_first_host = false;

							while(grid.get_child_at(1,results) != null) {
								HostItem _item = (HostItem) grid.get_child_at(1,results);
								settings.write_host_item(_item, is_first_host);

								if (!is_first_host) {
									is_first_host = !is_first_host;
								}

								results++;
							}
						}
						return false;
					});

				}
				return false;
			});

            grid.attach(hi, 1, item_index,1,1);
            item_index++;
        }

        if (item_index > 0) grid.show_all();


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
            item.editOrDone.clicked.connect(() => {
			    int results = 0;
			    bool is_first_host = false;

				while(grid.get_child_at(1,results) != null) {
					HostItem? _item = (HostItem) grid.get_child_at(1,results);
					settings.write_host_item(_item, is_first_host);

					if (!is_first_host) {
						is_first_host = !is_first_host;
					}

					results++;
				}
            });

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

							int host_item_index = find_index_of_item(grid, item, 1);
							stdout.printf("host item %s have index %d\n", item.nickname, host_item_index);

							if (host_item_index != -1) {
								grid.remove_row(host_item_index);
							}

							grid.show_all();

   						    int results = 0;
   						    bool is_first_host = false;

							while(grid.get_child_at(1,results) != null) {
								HostItem _item = (HostItem) grid.get_child_at(1,results);
								settings.write_host_item(_item, is_first_host);

								if (!is_first_host) {
									is_first_host = !is_first_host;
								}

								results++;
							}
						}
						return false;
					});

				}
				return false;
			});

			settings.write_host_item(item, true);
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
		 	return new Gtk.Image();
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

	/*
	 *  Locate the index of the row in the grid
	 */
	private int find_index_of_item(Gtk.Grid grid, HostItem item, int column) {
        int results = 0;
        while(grid.get_child_at(column,results) != null) {
        	HostItem _compare = (HostItem) grid.get_child_at(column, results);
        	if (_compare == item) return results;
            results++;
        }
		return -1;
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

//    Application postcix = new Application ();
//    postcix.show_all();

    HostItem? fake_item = new HostItem.with_values("localhost", "localhost", 5432, "migo","", "migo");
    PostgreSQL postgres = new PostgreSQL.with_host(fake_item);
    DatabaseView db_view = new DatabaseView();
    db_view.show_all();

    Gtk.main ();
    return 0;
}
