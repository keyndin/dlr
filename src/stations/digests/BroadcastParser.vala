public class BroadcastParser : Deserializable {
    public Array<Broadcast> broadcasts { get; set; }
    public string uri { get; set; default = ""; }

    public override void parse(string station_display_name) {

        broadcasts = new Array<Broadcast>();

        // Get XML from URL and parse result
        base.get_from_uri(uri);
        find_all_by_key("item", station_display_name);
    }

    public override void find_all_by_key(string key, string station_display_name){

        for (Xml.Node* iter = base.root->children; iter != null; iter = iter->next){
            if (!base.is_element_node(iter)) {
                // Spaces between tags are handled as nodes too, skip them
                continue;
            }

            if (iter->name == key) {
                var broadcast_id = int.parse(iter->get_prop("id"));
                var broadcast = new Broadcast();
                broadcast.broadcast_title = iter->get_content().normalize();
                broadcast.broadcast_id = broadcast_id;
                broadcast.station_display_name = station_display_name;
                broadcasts.append_val(broadcast);
            }

        }
    }
}
