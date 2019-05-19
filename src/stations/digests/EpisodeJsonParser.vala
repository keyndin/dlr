public class EpisodeJsonParser : AircheckJsonParser<Episode>{
    public Array<Episode> episodes { get; set; }
    public string uri { get; set; default = ""; }

    public void parse() {
        // Get Json from URL and parse result
        base.get_from_uri(uri);

        Episode episode = base.JsonResult;
        episodes.append_val(episode);
    }
}