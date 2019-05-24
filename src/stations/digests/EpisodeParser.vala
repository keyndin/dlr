public class EpisodeParser : Deserializable {
    public Array<Episode> episodes { get; set; }
    public string uri { get; set; default = ""; }

    public override void parse() {
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
                var episode = new Episode();
                episode.episode_id = int.parse(iter->get_prop("id"));
                episode.episode_url = iter->get_prop("url");
                episode.episode_duration = int.parse(iter->get_prop("duration"));
                episode.episode_timestamp = int.parse(iter->get_prop("timestamp"));

                for (Xml.Node* child = iter->children; child != null; child = child->next){
                    if (!base.is_element_node(iter)) {
                        // Spaces between tags are handled as nodes too, skip them
                        continue;
                    }

                    if(child->name == "title")
                        episode.episode_description = child->get_content().normalize();
                    if(child->name == "author")
                        episode.episode_author = child->get_content().normalize();
                    if(child->name == "sendung")
                        episode.broadcast_id = int.parse(iter->get_prop("id"));

                }
                print_indent(episode.episode_id, episode.episode_description);
                episodes.append_val(episode);
            }
        }
    }

    private void print_indent (int node_id, string content, char bullet = '*'){
      string indent = string.nfill(4, ' ');
      stdout.printf("%s%c%s: %s\n", indent, bullet, node_id.to_string(), content);
    }

}
