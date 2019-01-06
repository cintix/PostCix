
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

        foreach (string db in database.get_databases()) {
            print("Database : %s\n", db);
        }
        print("============================\n\n");

		destroy.connect(this.close_and_show_favorits);
		title = "PostgreSQL - " + item.nickname;
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

        Gtk.TreeView treeview = new TreeView ();
        setup_treeview (treeview);
        treeview.vexpand = true;
        treeview.height_request = paned.get_allocated_height();

        paned.add1(treeview);
        paned.add2(new Gtk.Entry());
        paned.vexpand = true;

        grid.attach(paned,0,1,1,1);
        grid.show_all();

	}


    private void setup_treeview (TreeView view) {

        Gtk.TreeStore store = new TreeStore (1, typeof (string));
        view.set_model (store);


        string schema = "";

        TreeIter root;
        TreeIter table_iter;
        TreeIter view_iter;
        TreeIter schema_iter = new TreeIter();

        view.insert_column_with_attributes (-1, "Overview", new CellRendererText (), "text", 0, null);
        store.append (out root, null);
        store.set(root,0,"Tables", -1);

        foreach (DatabaseItem db in database.get_tables()) {
            if (schema != db.schema) {
                store.append(out schema_iter, root);
                print("Schema is now %s\n", db.schema);
                store.set(schema_iter,0,db.schema, -1);
                schema = db.schema;
            }
            store.append(out table_iter, schema_iter);
            store.set(table_iter,0,db.name, -1);
        }


        store.append (out root, null);
        store.set(root,0,"Views", -1);

        foreach (DatabaseItem db in database.get_views()) {
            if (schema != db.schema) {
                store.append(out schema_iter, root);
                store.set(schema_iter,0,db.schema, -1);
                schema = db.schema;
            }
            store.append(out table_iter, schema_iter);
            store.set(table_iter,0,db.name, -1);
        }

   }

	public void close_and_show_favorits() {
        favorite.show_all();
		this.close;
	}

}
