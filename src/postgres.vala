
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

		stdout.printf("Logging in to database %s \n", _item.database_name);

		stdout.printf("db status: %s \n", database.get_status ().to_string());
		stdout.printf("db status: %s \n",database.get_error_message ());

        /* Check to see that the backend connection was successfully made */
        if (database.get_status () != ConnectionStatus.OK) {
            stderr.printf ("Connection to database failed: %s", database.get_error_message ());
            return ;
        }

		stdout.printf("Connected to %s \n", _item.database_name);

    }



    public string[] get_databases() {
        string[] list = {};
        /* Check to see that the backend connection was successfully made */
        if (database.get_status () != ConnectionStatus.OK) {
            stderr.printf ("Connection to database failed: %s", database.get_error_message ());
            return {};
        }

        Result res = database.exec ("SELECT datname FROM pg_database WHERE datistemplate = false order by datname;");

        if (res.get_status () != ExecStatus.TUPLES_OK) {
            stderr.printf ("SQL failed: %s", database.get_error_message ());
            return{};
        }

         /* next, print out the rows */
        for (int i = 0; i < res.get_n_tuples(); i++) {
             list += res.get_value (i, 0);
        }

        return list;
    }


    public DatabaseItem[] get_tables() {
        DatabaseItem[] list = {};
        /* Check to see that the backend connection was successfully made */
        if (database.get_status () != ConnectionStatus.OK) {
            stderr.printf ("Connection to database failed: %s", database.get_error_message ());
            return {};
        }

        Result res = database.exec ("SELECT * FROM pg_catalog.pg_tables order by tablename;");

        if (res.get_status () != ExecStatus.TUPLES_OK) {
            stderr.printf ("SQL failed: %s", database.get_error_message ());
            return {};
        }

         /* next, print out the rows */
        for (int i = 0; i < res.get_n_tuples(); i++) {
             DatabaseItem di = new DatabaseItem(res.get_value (i, 1),res.get_value (i, 0),"");
             list += di;
        }

/*
        int nFields = res.get_n_fields ();
        for (int i = 0; i < nFields; i++) {
            stdout.printf ("%-15s", res.get_field_name (i));
        }
        stdout.printf ("\n");

        for (int i = 0; i < res.get_n_tuples(); i++) {
            for (int j = 0; j < nFields; j++) {
                stdout.printf ("%-15s", res.get_value (i, j));
            }
            stdout.printf ("\n");
        }

        stdout.printf("\n[%d Rows...]\n", res.get_n_tuples());
*/

        return list;
    }

    public DatabaseItem[] get_views() {
        DatabaseItem[] list = {};
        /* Check to see that the backend connection was successfully made */
        if (database.get_status () != ConnectionStatus.OK) {
            stderr.printf ("Connection to database failed: %s", database.get_error_message ());
            return {};
        }

        Result res = database.exec ("SELECT * FROM pg_catalog.pg_views order by viewname;");

        if (res.get_status () != ExecStatus.TUPLES_OK) {
            stderr.printf ("SQL failed: %s", database.get_error_message ());
            return {};
        }

         /* next, print out the rows */
        for (int i = 0; i < res.get_n_tuples(); i++) {
             DatabaseItem di = new DatabaseItem(res.get_value (i, 1),res.get_value (i, 0),res.get_value (i, 3));
             list += di;

        }

/*
        int nFields = res.get_n_fields ();
        for (int i = 0; i < nFields; i++) {
            stdout.printf ("%-15s", res.get_field_name (i));
        }
        stdout.printf ("\n");


        for (int i = 0; i < res.get_n_tuples(); i++) {
            for (int j = 0; j < nFields; j++) {
                stdout.printf ("%-15s", res.get_value (i, j));
            }
            stdout.printf ("\n");
        }

        stdout.printf("\n[%d Rows...]\n", res.get_n_tuples());
*/
        return list;
    }




   ~PostgreSQL() {
		if (database != null) {
			database.reset();
		}
   }
 }
