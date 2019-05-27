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
        for (Xml.Node* iter = base.root->children; iter != null; iter = iter->next){
            if (!base.is_element_node(iter)) {
                // Spaces between tags are handled as nodes too, skip them
                continue;
            }

            if (iter->name == key) {
                var episode = new Episode();
                episode.episode_id = int.parse(iter->get_prop("id"));
                episode.episode_url = iter->get_prop("url");
                episode.episode_duration = int.parse(iter->get_prop("duration"));
                episode.episode_timestamp = int.parse(iter->get_prop("timestamp"));

                int station_id = int.parse(iter->get_prop("station"));

                switch(station_id){
                    case 4: episode.station_display_name = "DLR";
                        break;
                    case 1: episode.station_display_name = "Nova";
                        break;
                    case 3: episode.station_display_name = "Kultur";
                        break;
                    default: assert_not_reached();
                }

                for (Xml.Node* child = iter->children; child != null; child = child->next){
                    if (!base.is_element_node(iter)) {
                        // Spaces between tags are handled as nodes too, skip them
                        continue;
                    }

                    if(child->name == "title")
                        episode.episode_description = child->get_content().normalize();
                    if(child->name == "author")
                        episode.episode_author = child->get_content().normalize();
                    if(child->name == "sendung"){
                        episode.broadcast_id = int.parse(child->get_prop("id"));
                        var broadcast_title = child->get_content().normalize();
                        if(broadcast_title != "") episode.broadcast_title = broadcast_title;
                        else
                            episode.broadcast_title = "Beitrag";
                    }

                }
                episodes.append_val(episode);
            }
        }
    }
}
