
using Gtk;
using Gdk;


public class DatabaseView : Gtk.Window {

	FavoriteWindow favorite;
	PostgreSQL database;
	HostItem item;

    Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
    Grid grid = new Gtk.Grid();


    /*
     * Setup database view
     */
	public DatabaseView(FavoriteWindow _f, PostgreSQL _p, HostItem _h) {

		this.favorite = _f;
		this.database = _p;
		this.item = _h;


		destroy.connect(this.close_and_show_favorits);
		title = "PostgreSQL connect - " + item.nickname;
		set_default_size(800,600);
		window_position = Gtk.WindowPosition.CENTER;

		favorite.hide();

        grid.column_homogeneous = true;

        add(grid);

		// The Toolbar:
		Gtk.ActionBar bar = new Gtk.ActionBar ();
		bar.set_size_request(get_allocated_width(), 30);

		grid.attach(bar,0,0,1,1);

		// Toolbar content:
		Gtk.Image img = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
		Gtk.ToolButton button1 = new Gtk.ToolButton (img, null);
		button1.clicked.connect (() => {
			print ("Button 1\n");
		});
		bar.add (button1);

		img = new Gtk.Image.from_icon_name ("window-close", Gtk.IconSize.SMALL_TOOLBAR);
		Gtk.ToolButton button2 = new Gtk.ToolButton (img, null);
		button2.clicked.connect (() => {
			print ("Button 2\n");
		});
		bar.add (button2);

        Paned paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.position = 210;

        Gtk.TreeView view = new TreeView ();
        setup_treeview (view);

        paned.add1(view);
        paned.add2(new Gtk.Entry());

        grid.attach(paned,0,1,1,1);
        grid.show_all();

	}


    private void setup_treeview (TreeView view) {

        Gtk.TreeStore store = new TreeStore (1, typeof (string));
        view.set_model (store);

        view.insert_column_with_attributes (-1, "Product", new CellRendererText (), "text", 0, null);

        TreeIter root;
        TreeIter category_iter;
        TreeIter product_iter;

        store.append (out root, null);
        store.set (root, 0, "All Products", -1);

        store.append (out category_iter, root);
        store.set (category_iter, 0, "Books", -1);

        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Moby Dick", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Heart of Darkness", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Ulysses", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Effective Vala", -1);

        store.append (out category_iter, root);
        store.set (category_iter, 0, "Films", -1);

        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Amores Perros", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Twin Peaks", -1);
        store.append (out product_iter, category_iter);
        store.set (product_iter, 0, "Vertigo", -1);

        view.expand_all ();
    }

	public void close_and_show_favorits() {
        favorite.show_all();
		this.close;
	}

}
