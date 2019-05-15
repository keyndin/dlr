public class EpisodeParser : Deserializable {
    public Array<Episode> episodes { get; set; }
    public string uri { get; set; default = ""; }

    public override void parse() {
        // Get XML from URL and parse result
        base.get_from_uri(uri);

        //ToDo: Loop over all xml-items and their children, parse children
        Episode episode = new Episode();
        episode.episode_description = base.find_key("item");

    }
}
