
using Gtk;
using Gdk;
using Postgres;

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

	private File cacheSQLFile = File.new_for_path (".postcix/sql.cache");

    /*
     * Setup database view
     */
	public DatabaseView(FavoriteWindow _f, PostgreSQL _p, HostItem _h) {

		this.favorite = _f;
		this.database = _p;
		this.item = _h;


		string my_css = ".sourceCode { font-size: 16px; }";

		apply_custom_css(my_css);

        foreach (string db in database.get_databases()) {
            stdout.printf("Database : %s\n", db);
        }

        stdout.printf("============================\n\n");

		destroy.connect(this.close_and_show_favorits);
		title = "PostgreSQL - " + item.nickname;
		set_default_size(800,600);
		window_position = Gtk.WindowPosition.CENTER;
		icon = imanager.load_image_into_buffer(".postcix/img/app_icon.png", 300,300);

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
			GLib.print ("Button 1\n");
		});
		bar.add (button1);

		img = new Gtk.Image.from_icon_name ("window-close", Gtk.IconSize.SMALL_TOOLBAR);
		Gtk.ToolButton button2 = new Gtk.ToolButton (img, null);
		button2.clicked.connect (() => {
			GLib.print ("Button 2\n");
		});
		bar.add (button2);

        paned.position = 210;

        treeview = new TreeView ();
        treeviewResults = new TreeView ();

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
		buffer.style_scheme = style_scheme_manager.get_scheme ("oblivion");
		buffer.language = language_manager.get_language ("sql");


		source_view = new Gtk.SourceView.with_buffer (buffer);
		source_view.get_style_context().add_class("sourceCode");

		source_view.key_press_event.connect(SQL_keypress);
        source_view.set_wrap_mode (Gtk.WrapMode.WORD);
        source_view.highlight_current_line = true;
		source_view.indent_width = 4;
		source_view.indent_on_tab = true;
		source_view.show_line_numbers = true;
        source_view.buffer.text = IOHandler.read_file(cacheSQLFile);

		ScrolledWindow source_view_scrolled_window = new Gtk.ScrolledWindow (null, null);
        source_view_scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        source_view_scrolled_window.add (source_view);
        source_view_scrolled_window.hexpand = true;
		source_view_scrolled_window.vexpand = true;

		//build_result(treeviewResults, database.query("select now()"));

		ScrolledWindow result_window = new Gtk.ScrolledWindow (null, null);
        result_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        result_window.add (treeviewResults);
        result_window.hexpand = true;
		result_window.vexpand = true;


		result_window.show_all();



		SQLpaned.add1(source_view_scrolled_window);
		SQLpaned.add2(result_window);
		SQLpaned.position = 250;
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


        paned.add2(SQLpaned);
        paned.vexpand = true;
		paned.show_all();


        grid.attach(paned,0,1,1,1);
        grid.show_all();
	}

	private bool SQL_keypress(EventKey event) {

		TextBuffer buffer = source_view.get_buffer();
		if (buffer.get_modified()) {
			IOHandler.write_file(cacheSQLFile, source_view.buffer.text);
		}

		if (event.state.to_string() == "GDK_CONTROL_MASK") {
			if (event.keyval == 0xff0d) {

				int refpoint = buffer.cursor_position;

				stdout.printf("cursor at %d \n" , refpoint);
				if (buffer.get_has_selection ()) {
					TextIter selection_start;
					TextIter selection_end;

					buffer.get_selection_bounds(out selection_start, out selection_end);

					string selection_sql = buffer.get_text(selection_start, selection_end, true);


					stdout.printf("Using selection text  %s \n" , selection_sql);
				    build_result(treeviewResults, database.query(selection_sql));
					treeviewResults.columns_autosize();

					return true;
				}




				build_result(treeviewResults, database.query(source_view.buffer.text));
				treeviewResults.columns_autosize();
				return true;
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

			if (command != "#SQL") {
				build_result(treeviewResults, database.query("select * from " + command + " limit 1000"));
				treeviewResults.columns_autosize();
			}

		}

	}

	public void change_database(Gtk.ComboBox combo) {
		if (combo.get_active () !=selected_database_index) {

		    stdout.printf("switching to database %s \n", database_list[combo.get_active ()]);
		    selected_database_index = combo.get_active();
		    combo.set_active(selected_database_index);

		    HostItem hi = database.item;
		    hi.database_name = database_list[selected_database_index];

			database = new PostgreSQL.with_host(hi);
		    setup_treeview (treeview);
			treeview.show_all();
		}
	}

    private void build_result (TreeView result_view, Result res) {
		if (result_view != null && result_view.get_columns() != null)
		foreach(TreeViewColumn tvc in result_view.get_columns()) {
			result_view.remove_column(tvc);
		}

        result_view.set_enable_tree_lines(true);
        result_view.set_grid_lines(TreeViewGridLines.BOTH);
        result_view.set_rules_hint(true);

		if (res == null) {
		  return;
		} else {
	        if (res.get_status () != ExecStatus.TUPLES_OK) {
	        	return;
	        }
        }


		// label = "Hitme";
		int nFields = res.get_n_fields ();
    	GLib.Type[] column_types = new GLib.Type[nFields + 1];
    	for (int i  =0; i < nFields; i ++ ) {
			stdout.printf("field column name %s \n", res.get_field_name(i));
    		string field_type = database.get_field_type((int) res.get_field_type(i));
			string field_name = res.get_field_name(i);
			field_name = field_name.replace("_","__");

			if (field_type == "bool") {
			    CellRendererToggle  crt = new CellRendererToggle ();
			    result_view.insert_column_with_attributes (-1, field_name, crt, "active", i, null);
			    column_types[i] = typeof(bool);
			} else {
			    CellRendererText  crt = new CellRendererText ();
			    crt.editable = true;
			    if (i > 0) {
					crt.single_paragraph_mode = true;
				}

			    result_view.insert_column_with_attributes (-1, field_name, crt, "text", i, null);
			    column_types[i] = typeof(string);
	        }

	        result_view.get_column(i).set_sort_column_id(i);
	        result_view.get_column(i).set_sort_order((i == 0) ? SortType.ASCENDING : SortType.DESCENDING);
	        result_view.get_column(i).clicked.connect(tv_header_clicked);
    	}

		column_types[nFields] = typeof (string);

        TreeIter root = new TreeIter();
		Gtk.ListStore store = new Gtk.ListStore.newv(column_types);
        result_view.set_model (store);
        result_view.set_headers_visible(true);

        for (int row  =0; row < res.get_n_tuples(); row++ ) {
		    store.append (out root);
			for (int col  =0; col < nFields; col++ ) {
				if (column_types[col] == typeof(string)) {
			    	store.set(root,col,res.get_value(row,col), -1);
			    }

				if (column_types[col] == typeof(bool)) {
			    	store.set(root,col,(res.get_value(row,col) == "t" ? true : false), -1);
			    }

			}
    	}
		result_view.set_headers_clickable(true);
		result_view.show_all();
	}


	private void tv_header_clicked(Gtk.TreeViewColumn _column){
		stdout.printf("Okay so i got called by column %s \n", _column.get_title ());
		if (_column.get_sort_order() == SortType.ASCENDING) {
			_column.set_sort_order(SortType.DESCENDING);
		} else {
			_column.set_sort_order(SortType.ASCENDING);
		}
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




	/*
	 * Apply Css styles to document
	 */
	private void apply_custom_css(string cssString) {
		try {
		    Gtk.CssProvider css_provider = new Gtk.CssProvider ();
		    css_provider.load_from_data(cssString, cssString.length);
		    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		} catch (Error e) {
			return;
		}
		return;
	}


}
