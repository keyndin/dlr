public class BroadcastParser : Deserializable {
    public Array<Broadcast> broadcasts { get; set; }
    public string uri { get; set; default = ""; }

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
                if(broadcast_id != 769){

                    var broadcast = new Broadcast();
                    broadcast.broadcast_title = iter->get_content().normalize();
                    broadcast.broadcast_id = broadcast_id;
                    print_indent(broadcast.broadcast_id, broadcast.broadcast_title);
                    broadcasts.append_val(broadcast);
                }
            }

        }
    }

    private void print_indent (int node_id, string content, char bullet = '*'){
      string indent = string.nfill(4, ' ');
      stdout.printf("%s%c%s: %s\n", indent, bullet, node_id.to_string(), content);
    }

}
