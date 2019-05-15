public class BroadcastParser : Deserializable {
    public Array<Broadcast> broadcasts { get; set; }
    public string uri { get; set; default = ""; }

    public override void parse() {
        // Get XML from URL and parse result
        base.get_from_uri(uri);

        //ToDo: Deserializable find_all_keys(string key)
        //ToDo: Get broadcast_id from xml-item
        //ToDo: Loop over all xml-items
        //ToDo: Get Episodes per Broadcast
        Broadcast broadcast = new Broadcast();
        broadcast.broadcast_title = base.find_key("item");
        broadcasts.append_val(broadcast);
    }
}
