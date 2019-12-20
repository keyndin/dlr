public class BroadcastParser : Deserializable {
    public Array<Broadcast> broadcasts { get; set; }
    public string uri { get; set; default = ""; }
    public E_StationNames station;

    public BroadcastParser(E_StationNames station) {
        this.station = station;
    }

    public override void parse() {

        broadcasts = new Array<Broadcast>();

        // Get XML from URL and parse result
        base.get_from_uri(uri);
        find_all_by_key("item");
    }

    public override void find_all_by_key(string key){
        for (Xml.Node* iter = base.root->children; iter != null; iter = iter->next){
            if (!base.is_element_node(iter)) {
                // Spaces between tags are handled as nodes too, skip them
                continue;
            }
            if (iter->name == key) {
                var broadcast_id = int.parse(iter->get_prop("id"));
                var broadcast = new Broadcast();
                broadcast.title = iter->get_content().normalize();
                broadcast.id = broadcast_id;
                broadcast.station = station.to_display_string();
                broadcasts.append_val(broadcast);
            }

        }
    }
}
