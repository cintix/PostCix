
using Gtk;
using Gdk;

using GLib;
using Postgres;


public class PostgreSQL : Object {
    public HostItem item;
    public Map<int, string> types = new Map<int,string>();

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

		stdout.printf("Building types overview\n");

		Result res = query("select oid, typname from pg_type;");
        if (res.get_status () != ExecStatus.TUPLES_OK) {
            stderr.printf ("SQL failed: %s", database.get_error_message ());
            return;
        }

        for (int i = 0; i < res.get_n_tuples(); i++) {
        	stdout.printf("type %s id %s\n",res.get_value (i, 0),res.get_value (i, 1));
			types.set_key(int.parse(res.get_value (i, 0)), res.get_value (i, 1));
        }


    }

	public void get_primary_key(string table) {
		string sql = "SELECT
							c.column_name, c.data_type
	  				  FROM
							information_schema.table_constraints tc
					  JOIN information_schema.constraint_column_usage AS ccu USING (constraint_schema, constraint_name)
					  JOIN information_schema.columns AS c ON c.table_schema = tc.constraint_schema AND tc.table_name = c.table_name AND ccu.column_name = c.column_name
					  where constraint_type = 'PRIMARY KEY' and tc.table_name = '" + table + "';";
	}


	public string get_field_type(int type_id) {
		return types.get_key(type_id);
	}


	public Result query(string sql) {

        /* Check to see that the backend connection was successfully made */
        if (database.get_status () != ConnectionStatus.OK) {
            stderr.printf ("Connection to database failed: %s", database.get_error_message ());
            return null;
        }
		stdout.printf("Executing SQL : %s\n", sql);
		return database.exec (sql);
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

        return list;
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

   ~PostgreSQL() {
		if (database != null) {
			database.reset();
		}
   }
 }
