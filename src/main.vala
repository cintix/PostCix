
using Gtk;
using Gdk;

int main (string[] args) {
    Gtk.init (ref args);


    FavoriteWindow favorite = new FavoriteWindow ();
    favorite.show_all();

    Gtk.main ();
    return 0;
}
