using Xml;
#if !LINUX
using Soup;
#endif

public abstract class Deserializable {

    protected Xml.Doc* doc;
    protected Xml.Node* root;

    ~Deserializable() {
        cleanup();
    }

    public abstract void parse();

    public void cleanup() {
        // libxml has manual memory management...
        delete doc;
        Parser.cleanup();
    }

    protected void get_from_uri(string uri) {
        // Get XML from URL and parse result
        var raw = read_from_uri(uri);

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
        // Since some systemcalls are handeled differently 
        // on Linux / Mac / Windows, e.g. how files are
        // opened, we have to accomendate for these 
        // differences
#if LINUX
        string line;
        string res = "";
        try {
            var file = File.new_for_uri(uri);
            var content = file.read();
            var dis = new DataInputStream(content);

            while ((line = dis.read_line(null)) != null) {
                // append all lines to res
                res += line;
            }
            return res;
        } catch (GLib.Error e) {
            stdout.printf("Error while opening stream: %s", e.message);
            return res;
        }
#else
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", uri);

        session.send_message (message);
        string res = (string) message.response_body.data;
        return res;
#endif
    }


}
