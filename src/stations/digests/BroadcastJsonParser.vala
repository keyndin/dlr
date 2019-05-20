public class BroadcastJsonParser : A_JsonParser<Broadcast>{
    public Array<Broadcast> broadcasts { get; set; }
    public string uri { get; set; default = ""; }

    public void parse() {
        // Get Json from URL and parse result
        base.get_from_uri(uri);

        Broadcast broadcast = base.JsonResult;
        broadcasts.append_val(broadcast);
    }
}