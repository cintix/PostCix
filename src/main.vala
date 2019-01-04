
using Gtk;
using Gdk;

int main (string[] args) {
    Gtk.init (ref args);


    FavoriteWindow postcix = new FavoriteWindow ();
    postcix.show_all();


    HostItem? fake_item = new HostItem.with_values("epg - local", "localhost", 5432, "epg_child_user","epgpass", "egpcore_child");
    PostgreSQL postgres = new PostgreSQL.with_host(fake_item);
    DatabaseView db_view = new DatabaseView();
    db_view.show_all();

    Gtk.main ();
    return 0;
}
