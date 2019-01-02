using Gtk;
using Gdk;


public class HostItem : Gtk.Box {
	bool expanded = false;
	DrawingArea area = new Gtk.DrawingArea();

	public HostItem () {

		//set_size_request(350, 100);
		set_redraw_on_allocate(true);
		area.set_size_request(350, 100);

		area.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK |
					    Gdk.EventMask.BUTTON_PRESS_MASK);

		Fixed layout = new Gtk.Fixed();

		layout.put(area, 0,0);
		Label connectionName = new Gtk.Label("#Unnamed");
		connectionName.set_size_request(300, 12);
		connectionName.set_markup("<b><span foreground=\"black\">#Unnamed</span></b>");
		connectionName.set_alignment(0,0);
		layout.put(connectionName, 15,15);

		Button connect = new Gtk.Button();
		connect.set_label("Connect");
		layout.put(connect, 250, 60);

		Button editOrDone = new Gtk.Button();
	    editOrDone.set_label("Edit");
		layout.put(editOrDone, 185,60);


		area.button_press_event.connect((event) => {
			toggleExpanding();
			if (expanded) {
				area.set_size_request(350, 300);
				//set_size_request(350, 300);
				editOrDone.set_label("Done");
				layout.put(connect, 250, 260);
				layout.put(editOrDone, 185,260);
			} else {
				area.set_size_request(350, 100);
				//set_size_request(350, 100);
			    editOrDone.set_label("Edit");
				layout.put(connect, 250, 60);
				layout.put(editOrDone, 185,60);
			}


			return false;
		});

		area.draw.connect((context) => {

			int height = area.get_allocated_height ();
			int width = area.get_allocated_width ();

			draw_rounded_path(context,5,5, width - 10, height -10, 6);
			//set_color (context, 212,191,224);
			set_color (context, 198,198,198);
			context.fill();

			return true;
		});

		layout.show();
		add(layout);

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
