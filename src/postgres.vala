
using Gtk;
using Gdk;

using GLib;
using Postgres;


public class PostgreSQL : Object {
    public HostItem item;

    public PostgreSQL() {

    }

    public PostgreSQL.with_host(HostItem _item) {
        this.item = _item;
    }


}
