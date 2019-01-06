

public class DatabaseItem: Object {
    public string name;
    public string schema;
    public string definition;

    public DatabaseItem(string _name, string _schema, string _definition) {
        this.name = _name;
        this.schema = _schema;
        this.definition = _definition;
    }
}
