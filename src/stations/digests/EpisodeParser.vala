public class EpisodeParser : Deserializable {
    public Array<Episode> episodes { get; set; }
    public string uri { get; set; default = ""; }

    public override void parse() {
        // Get XML from URL and parse result
        episodes = new Array<Episode>();
        base.get_from_uri(uri);
        find_all_by_key("item");
    }

    public override void find_all_by_key(string key){
        // TODO: we're missing desc...
        for (Xml.Node* iter = base.root->children; iter != null; iter = iter->next){
            if (!base.is_element_node(iter)) {
                // Spaces between tags are handled as nodes too, skip them
                continue;
            }
            if (iter->name == key) {
                string station = "", name = "", author = "";
                int station_id = int.parse(iter->get_prop("station"));
                station = E_StationNames.fromInt(station_id).to_display_string();

                for (Xml.Node* child = iter->children; child != null; child = child->next){
                    if (!base.is_element_node(iter)) {
                        // Spaces between tags are handled as nodes too, skip them
                        continue;
                    }

                    if (child->name == "title")
                        name = child->get_content().normalize();
                    if (child->name == "author")
                        author = child->get_content().normalize();
                    if (child->name == "sendung"){
                        name = child->get_content().normalize();
                        if (name == "") name = "Beitrag";
                    }

                }
                var episode = new Episode(name, station, iter->get_prop("url"));
                episode.id = int.parse(iter->get_prop("id"));
                episode.duration = int.parse(iter->get_prop("duration"));
                episode.timestamp = int.parse(iter->get_prop("timestamp"));
                episode.author = author;
                episodes.append_val(episode);
            }
        }
    }
}
