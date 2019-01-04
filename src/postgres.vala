
using Gtk;
using Gdk;

using GLib;
using Postgres;


public class PostgreSQL : Object {
    public HostItem item;
    private Database database;

    public PostgreSQL() {

    }

    public PostgreSQL.with_host(HostItem _item) {
        this.item = _item;
        this.database = Postgres.set_db_login(item.host, item.port.to_string(), "", "", item.database_name, item.username, item.password);

        /* Check to see that the backend connection was successfully made */
        if (database.get_status () != ConnectionStatus.OK) {
            stderr.printf ("Connection to database failed: %s", database.get_error_message ());
            return ;
        }

        Result res = database.exec ("select * from test;");

        if (res.get_status () != ExecStatus.TUPLES_OK) {
            stderr.printf ("SQL failed: %s", database.get_error_message ());
            return;
        }

        /* first, print out the attribute names */
        int nFields = res.get_n_fields ();
        for (int i = 0; i < nFields; i++) {
            stdout.printf ("%-15s", res.get_field_name (i));
        }
        stdout.printf ("\n");

         /* next, print out the rows */
        for (int i = 0; i < res.get_n_tuples(); i++) {
            for (int j = 0; j < nFields; j++) {
                stdout.printf ("%-15s", res.get_value (i, j));
            }
            stdout.printf ("\n");
        }

    }


}
