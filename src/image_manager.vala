

using Gtk;
using Gdk;

public class ImageManager : Object {

	/*
	 * Load image-file into buffer resize and convert to  image
	 */
	public Gtk.Image load_image(string file, int width, int height) {
		Pixbuf pixbuf;

		try {
		  pixbuf = load_image_into_buffer(file, width, height);
		 } catch (Error e) {
		 	return new Gtk.Image();
		 }

		Image image = new Gtk.Image();
		image.set_from_pixbuf(pixbuf);
		return image;
	}


/*
	 * Load image-file into buffer resize
	 */
	public Gdk.Pixbuf load_image_into_buffer(string file, int width, int height) {
		Pixbuf pixbuf;

		try {
		  pixbuf = new Gdk.Pixbuf.from_file(file);
		  pixbuf = pixbuf.scale_simple(width, height, Gdk.InterpType.BILINEAR);
		 } catch (Error e) {
		 	return null;
		 }

		return pixbuf;
	}


}
