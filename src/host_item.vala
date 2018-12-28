using Gtk;
using Gdk;


public class HostItem : Gtk.Box {
	bool expanded = false;
	DrawingArea area = new Gtk.DrawingArea();

	public HostItem () {

		area.set_size_request(350, 100);


		area.set_events(Gdk.EventMask.ENTER_NOTIFY_MASK |
					    Gdk.EventMask.BUTTON_PRESS_MASK);

		area.button_press_event.connect((event) => {
			toggleExpanding();
			if (expanded) {
				area.set_size_request(350, 300);
			} else {
				area.set_size_request(350, 100);
				Label connectionName = new Gtk.Label("#Unnamed");
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

		this.pack_start(area,false,false);
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
