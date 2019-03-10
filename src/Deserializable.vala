using Xml;

public  abstract class Deserializable {

    protected Xml.Doc* doc;
    protected Xml.Node* root;



    ~Deserializable() {
        cleanup();
    }

    public abstract void parse();

    protected void get_from_uri(string uri) {
        // Get XML from URL and parse result
        var raw = read_from_uri(uri);

        stdout.printf("\n\n%s\n\n", raw);

        doc = Xml.Parser.parse_memory(raw, raw.length);
        var root = doc->get_root_element();
        this.root = root;
    }

    protected string find_key (string key) {
        // Iterate over root node and find key

        for (Xml.Node* iter = root->children; iter != null; iter = iter->next) {
            if (iter->type != ElementType.ELEMENT_NODE) {
                // Spaces between tags are handled as nodes too, skip them
                continue;
            }

            if (iter->name == key) {
                return iter->get_content().normalize();
            }
        }

        return "NOT YET IMPLEMENTED";
    }

    protected string read_from_uri(string uri) {
        // Get content from URI and return it as string
        string line;
        string res = "";
        var file = File.new_for_uri(uri);

        var dis = new DataInputStream(file.read());


        while ((line = dis.read_line(null)) != null) {
            // append all lines to res
            res += line;
        }

        return res;
    }

    public void cleanup() {
        // libxml has manual memory management...
        delete doc;
        Parser.cleanup();
    }
}
