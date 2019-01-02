using Gtk;
using Gdk;


public class HostItem : Gtk.Fixed {
	bool expanded = false;
	DrawingArea area = new Gtk.DrawingArea();

	public HostItem () {

		//set_size_request(350, 100);
		set_redraw_on_allocate(true);
		area.set_size_request(350, 80);

		area.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK |
					    Gdk.EventMask.BUTTON_PRESS_MASK);

		put(area, 0,0);
		Label connectionName = new Gtk.Label("");
		connectionName.set_size_request(300, 12);
		connectionName.set_markup("<b><span foreground=\"black\">localhost</span></b>");
		connectionName.set_alignment(0,0);
		put(connectionName, 15,15);

		Button connect = new Gtk.Button();
		connect.set_label("Connect");
		put(connect, 250, 40);

		Button editOrDone = new Gtk.Button();
	    editOrDone.set_label("Edit");
		put(editOrDone, 185,40);


		Grid inputGrid = new Gtk.Grid();
		inputGrid.set_size_request(270, 250);
		inputGrid.set_row_spacing(2);
		inputGrid.set_column_spacing(2);
		inputGrid.set_column_homogeneous(false);

		Label name_lbl = new Gtk.Label("");
		name_lbl.set_markup("<span foreground=\"black\">Name</span>");
		name_lbl.set_size_request(50,15);

		Entry name_in = new Gtk.Entry();
		//name_in.set_size_request(100,15);
		name_in.set_text("localhost");

		inputGrid.attach(name_lbl, 0,0,1,1);
		inputGrid.attach(name_in, 1,0,3,1);


		Box top_horizontal_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1);
		top_horizontal_box.set_size_request(250,8);
		inputGrid.attach(top_horizontal_box, 1,1,3,1);



		Label host_lbl = new Gtk.Label("");
		host_lbl.set_markup("<span foreground=\"black\">Host</span>");
		host_lbl.set_size_request(40,15);


		Entry host_in = new Gtk.Entry();
		host_in.set_text("localhost");

		inputGrid.attach(host_lbl, 0,2,1,1);
		inputGrid.attach(host_in, 1,2,1,1);



		Label port_lbl = new Gtk.Label("");
		port_lbl.set_markup("<span foreground=\"black\">Port</span>");
		port_lbl.set_size_request(40,15);


		Entry port_in = new Gtk.Entry();
		port_in.set_size_request(10,15);
		port_in.set_width_chars(5);
		port_in.set_text("5432");

		inputGrid.attach(port_lbl, 2,2,1,1);
		inputGrid.attach(port_in, 3,2,1,1);

		Box horizontal_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 1);
		horizontal_box.set_size_request(250,4);
		inputGrid.attach(horizontal_box, 1,3,3,1);


		Label username_lbl = new Gtk.Label("");
		username_lbl.set_markup("<span foreground=\"black\">User</span>");
		//name_lbl.set_size_request(70,15);

		Entry username_in = new Gtk.Entry();
		//name_in.set_size_request(100,15);
		username_in.set_text("postgres");

		inputGrid.attach(username_lbl, 0,4,1,1);
		inputGrid.attach(username_in, 1,4,2,1);

		Label pass_lbl = new Gtk.Label("");
		pass_lbl.set_markup("<span foreground=\"black\">Pass</span>");
		//name_lbl.set_size_request(70,15);

		Entry pass_in = new Gtk.Entry();
		//name_in.set_size_request(100,15);
		pass_in.set_text("postgres");
		pass_in.set_invisible_char('*');
		pass_in.set_visibility(false);

		inputGrid.attach(pass_lbl, 0,5,1,1);
		inputGrid.attach(pass_in, 1,5,2,1);

		Label database_lbl = new Gtk.Label("");
		database_lbl.set_markup("<span foreground=\"black\">Db</span>");
		//name_lbl.set_size_request(70,15);

		Entry database_in = new Gtk.Entry();
		//name_in.set_size_request(100,15);
		database_in.set_text("postgres");

		inputGrid.attach(database_lbl, 0,6,1,1);
		inputGrid.attach(database_in, 1,6,2,1);


		put(inputGrid, -1000, -4000);


		area.button_press_event.connect((event) => {
			toggleExpanding();

			remove(connect);
			remove(connectionName);
			remove(editOrDone);
			remove(inputGrid);

			if (expanded) {
				area.set_size_request(350, 250);
				editOrDone.set_label("Done");
				put(connectionName, -1500,-1500);
				put(connect, 250, 210);
				put(editOrDone, 185,210);
				put(inputGrid, 15, 40);
			} else {
				area.set_size_request(350, 80);
			    editOrDone.set_label("Edit");
				put(connectionName, 15,15);
				put(connect, 250, 40);
				put(editOrDone, 185,40);
				put(inputGrid, -1000, -4000);
			}

			return false;
		});

		area.draw.connect((context) => {

			int height = area.get_allocated_height ();
			int width = area.get_allocated_width ();

			draw_rounded_path(context,5,5, width - 10, height -10, 6);
			set_color (context, 198,198,198);
			context.fill();

			return true;
		});

	    editOrDone.clicked.connect(() => { toggleExpanding();

			remove(connect);
			remove(connectionName);
			remove(editOrDone);
			remove(inputGrid);

			if (expanded) {
				area.set_size_request(350, 250);
				editOrDone.set_label("Done");
				put(connectionName, -1500,-1500);
				put(connect, 250, 210);
				put(editOrDone, 185,210);
				put(inputGrid, 15, 40);
			} else {
				area.set_size_request(350, 80);
			    editOrDone.set_label("Edit");
				put(connectionName, 15,15);
				put(connect, 250, 40);
				put(editOrDone, 185,40);
				put(inputGrid, -1000, -4000);
			}

			});

		name_in.preedit_changed.connect(() => {
			stdout.printf(name_in.get_text());
		});


   }

   private void toggleExpanding() {
   		expanded = !expanded;
   }

   private void draw_rounded_path(Cairo.Context ctx, double x, double y, double width, double height, double radius) {
	   double degrees = Math.PI / 180.0;
   	   ctx.new_sub_path();
   	   ctx.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
       ctx.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
       ctx.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
       ctx.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
       ctx.close_path();
   }


   private void set_color(Cairo.Context ctx, double red, double blue, double green) {
   	   ctx.set_source_rgb(red / 255, blue /255,green /255);
   }

}
