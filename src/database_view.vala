
using Gtk;
using Gdk;


public class DatabaseView : Gtk.Window {

	FavoriteWindow favorite;
	PostgreSQL database;
	HostItem item;

	ImageManager imanager = new ImageManager();
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

		ScrolledWindow scroll_treeview = new Gtk.ScrolledWindow(null,null);
		scroll_treeview.hexpand = true;
		scroll_treeview.vexpand = true;
		scroll_treeview.border_width = 2;
		scroll_treeview.hscrollbar_policy = Gtk.PolicyType.ALWAYS;
		scroll_treeview.add(treeview);
		scroll_treeview.show();

        paned.add1(scroll_treeview);
        paned.add2(new Gtk.Entry());
        paned.vexpand = true;

        grid.attach(paned,0,1,1,1);
        grid.show_all();
	}


    private void setup_treeview (TreeView view) {

        Gtk.TreeStore store = new TreeStore (2, typeof(Pixbuf),  typeof (string));
        view.set_model (store);
		view.set_headers_visible(false);

        string schema = "";

        TreeIter root = new TreeIter();
        TreeIter schema_iter = new TreeIter();

        view.insert_column_with_attributes (-1, "Icon", new CellRendererPixbuf (), "pixbuf", 0, null);
        view.insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", 1, null);

		Pixbuf table_icon = imanager.load_image_into_buffer(".postcix/img/table_icon.png", 16,16);
        DatabaseItem[] table_items = database.get_tables();

		foreach(DatabaseItem item in table_items) {
			if (item.schema == "public") {
				print("Table %s is in public\n", item.name);
		        store.append (out root, null);
		        store.set(root,0,table_icon, 1, item.name, -1);
			}
		}

		Pixbuf view_icon = imanager.load_image_into_buffer(".postcix/img/view_icon.png", 16,16);
        DatabaseItem[] view_items = database.get_tables();

		foreach(DatabaseItem item in view_items) {
			if (item.schema == "public") {
				print("Views %s is in public\n", item.name);
		        store.append (out root, null);
		        store.set(root,0,view_icon, 1, item.name, -1);
			}
		}


		/*
		 *  Added information_schema
		 */

		Pixbuf folder_icon = imanager.load_image_into_buffer(".postcix/img/folder.png", 16,16);
		store.append(out root, null);
        store.set(root,0, folder_icon, 1,"information_schema", -1);

		foreach(DatabaseItem item in table_items) {
			if (item.schema == "information_schema") {
		        store.append (out schema_iter, root);
		        store.set(schema_iter,0,table_icon, 1, item.name, -1);
			}
		}


		foreach(DatabaseItem item in view_items) {
			if (item.schema == "information_schema") {
		        store.append (out schema_iter, root);
		        store.set(schema_iter,0,view_icon, 1, item.name, -1);
			}
		}


		/*
		 *  Added pg_catalog
		 */

		store.append(out root, null);
        store.set(root,0, folder_icon, 1,"pg_catalog", -1);

		foreach(DatabaseItem item in table_items) {
			if (item.schema == "pg_catalog") {
		        store.append (out schema_iter, root);
		        store.set(schema_iter,0,table_icon, 1, item.name, -1);
			}
		}


		foreach(DatabaseItem item in view_items) {
			if (item.schema == "pg_catalog") {
		        store.append (out schema_iter, root);
		        store.set(schema_iter,0,view_icon, 1, item.name, -1);
			}
		}


/*
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
*/
   }

	public void close_and_show_favorits() {
        favorite.show_all();
		this.close;
	}

}
