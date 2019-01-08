
using Gtk;
using Gdk;


public class DatabaseView : Gtk.Window {

 	private SourceView source_view;
	private SourceLanguageManager language_manager;
	private FavoriteWindow favorite;
	private PostgreSQL database;
	private HostItem item;

	private ImageManager imanager = new ImageManager();
    private Setting settings = new Setting(File.new_for_path (".postcix/settings.conf"));
    private Grid grid = new Gtk.Grid();
    private Paned paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
    private Paned SQLpaned = new Gtk.Paned (Gtk.Orientation.VERTICAL);

	private Gtk.TreeView treeview;
	private Gtk.TreeView treeviewResults;

	private string[] database_list;
	private int selected_database_index = 0;


    /*
     * Setup database view
     */
	public DatabaseView(FavoriteWindow _f, PostgreSQL _p, HostItem _h) {

		this.favorite = _f;
		this.database = _p;
		this.item = _h;

		print ("Listing languages \n");
    	var ids = language_manager.get_language_ids ();
		foreach (var id in ids) {
		    var lang = language_manager.get_language (id);
		    print ("lang name %s/\n", lang.name);
		}


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

        paned.position = 210;

        treeview = new TreeView ();

        treeview.insert_column_with_attributes (-1, "Icon", new CellRendererPixbuf (), "pixbuf", 0, null);
        treeview.insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", 1, null);

        setup_treeview (treeview);

   		treeview.row_activated.connect(row_click);

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

		SourceBuffer buffer = new Gtk.SourceBuffer (null);
		SourceStyleSchemeManager style_scheme_manager = new Gtk.SourceStyleSchemeManager ();
		language_manager = Gtk.SourceLanguageManager.get_default ();

		buffer.highlight_syntax = true;
		buffer.highlight_matching_brackets = true;
		//buffer.style_scheme = style_scheme_manager.get_scheme ("oblivion");
		buffer.language = language_manager.get_language ("sql");


		source_view = new Gtk.SourceView.with_buffer (buffer);
		source_view.key_press_event.connect(SQL_keypress);
        source_view.set_wrap_mode (Gtk.WrapMode.WORD);
        source_view.highlight_current_line = true;
		source_view.indent_width = 4;
		source_view.indent_on_tab = true;
		source_view.show_line_numbers = true;
        source_view.buffer.text = "";

		ScrolledWindow source_view_scrolled_window = new Gtk.ScrolledWindow (null, null);
        source_view_scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        source_view_scrolled_window.add (source_view);
        source_view_scrolled_window.hexpand = true;
		source_view_scrolled_window.vexpand = true;




		ScrolledWindow result_window = new Gtk.ScrolledWindow (null, null);
        result_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        result_window.add (build_result ());
        result_window.hexpand = true;
		result_window.vexpand = true;



		//SQLpaned.add1(source_view_scrolled_window);
		//SQLpaned.add1(source_view_scrolled_window);

/*
 *

 SELECT      n.nspname as schema, t.typname as type, *
FROM        pg_type t
LEFT JOIN   pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE       (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
AND     NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
AND     n.nspname NOT IN ('pg_catalog', 'information_schema');


SELECT pg_type.typname AS enumtype,
     pg_enum.enumlabel AS enumlabel
 FROM pg_type
 JOIN pg_enum
     ON pg_enum.enumtypid = pg_type.oid;

 *
 */


        paned.add2(source_view_scrolled_window);
        paned.vexpand = true;



        grid.attach(paned,0,1,1,1);
        grid.show_all();
	}

	private bool SQL_keypress(EventKey event) {
		print ("state: %s value : %x \n", event.state.to_string(),event.keyval);
		if (event.state.to_string() == "GDK_CONTROL_MASK") {
			print("Control state matched \n");
			if (event.keyval == 0xff0d) {
				print("executing SQL %s \n", source_view.buffer.text);
			}
		}
		return false;
	}



	private void row_click(TreePath path, TreeViewColumn column) {
		TreeModel model;
		TreeIter  iter;
		TreeIter  parent_iter;

		TreeSelection selection = treeview.get_selection();
		if (selection.get_selected(out model, out iter)) {
			model.iter_parent(out parent_iter, iter);

			Value name;
			model.get_value(iter,1, out name);

			Value parent_name;
			model.get_value(parent_iter,1, out parent_name);
			string parent = parent_name.get_string();
			string command;
			if (parent != null) {
				command = parent  + "." + name.get_string();
			} else {
				command =  name.get_string();
			}

			print("You clicked %s \n",command);
		}

	}

	public void change_database(Gtk.ComboBox combo) {
		if (combo.get_active () !=selected_database_index) {

		    print("switching to database %s \n", database_list[combo.get_active ()]);
		    selected_database_index = combo.get_active();
		    combo.set_active(selected_database_index);

		    HostItem hi = database.item;
		    hi.database_name = database_list[selected_database_index];

			database = new PostgreSQL.with_host(hi);
		    setup_treeview (treeview);
			treeview.show_all();
		}
	}

    private TreeView build_result () {

    	TreeView result_view = new TreeView();
    	for (int i  =0; i < 10; i ++ ) {
	        treeview.insert_column_with_attributes (-1, "Column " + i.to_string(), new CellRendererText (), "text", i, null);
    	}

        TreeIter root = new TreeIter();
		Gtk.TreeStore store = treeview.model;

        for (int j  =0; j < 100; j ++ ) {
		    store.append (out root, null);
			for (int i  =0; i < 10; i ++ ) {
			    store.set(root,i,"string - " + i.to_string() + " row " + j.to_string(), 1, "String", -1);
			}
    	}

		result_view.show_all();
		return result_view;
	}

    private void setup_treeview (TreeView view) {

        Gtk.TreeStore store = new TreeStore (2, typeof(Pixbuf),  typeof (string));
        view.set_model (store);
		view.set_headers_visible(false);


        string schema = "";

        TreeIter root = new TreeIter();
        TreeIter schema_iter = new TreeIter();

		Pixbuf sql_icon = imanager.load_image_into_buffer(".postcix/img/comments-12.png", 16,16);
        store.append (out root, null);
        store.set(root,0,sql_icon, 1, "#SQL", -1);


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
