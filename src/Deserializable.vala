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
        // Since some systemcalls are handeled differently 
        // on Linux / Mac / Windows, e.g. how files are
        // opened, we have to accomendate for these 
        // differences
#if LINUX        
        return read_from_uri_linux(uri);        
#else
        return """<preview station="4">
<time_start>16:35 Uhr</time_start>
<name>Forschung aktuell</name>
<text>
Forschung aktuellTäglich das Neueste aus Naturwissenschaft, Medizin und Technik. Berichte, Reportagen und Interviews aus der Welt der Wissenschaft. Ob Astronomie, Biologie, Chemie, Geologie, Ökologie, Physik oder Raumfahrt: Forschung Aktuell liefert Wissen im Kontext und Bildung mit Unterhaltungswert.Mathematik hat einen miesen Ruf: Sie gilt als abstrakt, abgehoben und ohne Bezug zum Alltag. Welcher Irrtum! Unser Leben steckt voller Zahlen und Zusammenhänge. Mathematische Formeln bestimmen den Lauf der Gestirne und die Erfolgschancen bei der Partnerwahl. Sie machen den Zufall berechenbar und Steuersündern das Leben schwer. Sie verraten, wie man optimale Entscheidungen trifft und wem man im Zweifel am ehesten trauen kann. Sie faszinieren Menschen beruflich, privat und in der Schule. In einer fünfteiligen Sendereihe im Mathe-Monat März eröffnet der Zahlenversteher Professor Christian Hesse von der Universität Stuttgart Ihnen neue Horizonte - und die Augen dafür, welche Relevanz Mathe fürs Leben hat.Sendereihe Mathe fürs Leben - Von Zahlen und Zusammenhängen Die Mathematik der Liebe (1/5) Wissenschaftsmeldungen Sternzeit 11. März 2019 Klimasünder Astronauten Am Mikrofon: Ralf Krauter
</text>
<href/>
<href_text/>
</preview>""";
#endif
    }

    private string read_from_uri_linux(string uri) {
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
    }

    public void cleanup() {
        // libxml has manual memory management...
        delete doc;
        Parser.cleanup();
    }
}
