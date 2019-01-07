
using Gtk;
using Gdk;


public class DatabaseView : Gtk.Window {

	FavoriteWindow favorite;
	PostgreSQL database;
	HostItem item;

	ImageManager imanager = new ImageManager();
    Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
    Grid grid = new Gtk.Grid();
	Gtk.TreeView treeview;

	string[] database_list;
	int selected_database_index = 0;


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

		database_list = database.get_databases();
		Gtk.ListStore liststore = new Gtk.ListStore (2, typeof (Pixbuf), typeof (string));

		for (int i = 0; i < database_list.length; i++){
			Gtk.TreeIter iter;
			liststore.append (out iter);
			liststore.set (iter, 0, imanager.load_image_into_buffer(".postcix/img/databases.png", 20,20),1, database_list[i]);
		}

		Gtk.ComboBox combobox = new Gtk.ComboBox.with_model (liststore);

		Gtk.CellRendererText cell = new Gtk.CellRendererText ();
		Gtk.CellRendererPixbuf cell_pb = new Gtk.CellRendererPixbuf ();

		combobox.pack_start (cell_pb, false);
		combobox.pack_start (cell, false);

		combobox.set_attributes (cell_pb, "pixbuf", 0);
		combobox.set_attributes (cell, "text", 1);

		for (int i = 0; i <database_list.length; i++) {
		    if (item.database_name == database_list[i]) {
		        combobox.set_active (i);
		        selected_database_index = i;
		    }
		}

        combobox.changed.connect(change_database);

		bar.add(combobox);

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

        treeview = new TreeView ();
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

	private void row_click(TreePath path, TreeViewColumn column) {
		TreeModel model;
		TreeIter  iter;

		TreeSelection selection = treeview.get_selection();
		if (selection.get_selected(out model, out iter)) {
			Value name;
			model.get_value(iter,1, out name);
			print("You clicked %s \n", name.get_string () );
		}

	}

	public void change_database(Gtk.ComboBox combo) {
		if (combo.get_active () !=selected_database_index) {
		    print("switching to database %s \n", database_list[combo.get_active ()]);
		    selected_database_index = combo.get_active();
		    combo.set_active(selected_database_index);
		}
	}

    private void setup_treeview (TreeView view) {

        Gtk.TreeStore store = new TreeStore (2, typeof(Pixbuf),  typeof (string));
        view.set_model (store);
		view.set_headers_visible(false);

		view.row_activated.connect(row_click);

        string schema = "";

        TreeIter root = new TreeIter();
        TreeIter schema_iter = new TreeIter();

        view.insert_column_with_attributes (-1, "Icon", new CellRendererPixbuf (), "pixbuf", 0, null);
        view.insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", 1, null);

		Pixbuf sql_icon = imanager.load_image_into_buffer(".postcix/img/comments-12.png", 16,16);
        store.append (out root, null);
        store.set(root,0,sql_icon, 1, "SQL", -1);


		Pixbuf table_icon = imanager.load_image_into_buffer(".postcix/img/table_icon.png", 16,16);
        DatabaseItem[] table_items = database.get_tables();

		foreach(DatabaseItem _item in table_items) {
			if (_item.schema == "public") {
		        store.append (out root, null);
		        store.set(root,0,table_icon, 1, _item.name, -1);
			}
		}

		Pixbuf view_icon = imanager.load_image_into_buffer(".postcix/img/view_icon.png", 16,16);
        DatabaseItem[] view_items = database.get_views();

		foreach(DatabaseItem _item in view_items) {
			if (_item.schema == "public") {
		        store.append (out root, null);
		        store.set(root,0,view_icon, 1, _item.name, -1);
			}
		}


		/*
		 *  Added schema information
		 */

		Pixbuf folder_icon = imanager.load_image_into_buffer(".postcix/img/folder.png", 16,16);

        string[] created_schemas = {"public"};
        foreach(DatabaseItem _schema in table_items) {
            if (_schema.schema in created_schemas) {
                continue;
            } else {
                created_schemas += _schema.schema;
		        store.append(out root, null);
                store.set(root,0, folder_icon, 1,_schema.schema, -1);

		        foreach(DatabaseItem _item in table_items) {
			        if (_schema.schema == _item.schema) {
		                store.append (out schema_iter, root);
		                store.set(schema_iter,0,table_icon, 1, _item.name, -1);
			        }
		        }


		        foreach(DatabaseItem _item in view_items) {
			        if (_schema.schema == _item.schema) {
		                store.append (out schema_iter, root);
		                store.set(schema_iter,0,view_icon, 1, _item.name, -1);
			        }
		        }



            }
        }
  }

	public void close_and_show_favorits() {
        favorite.show_all();
		this.close;
	}

}
