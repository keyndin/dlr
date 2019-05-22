public class BroadcastParser : Deserializable {
    public Array<Broadcast> broadcasts { get; set; }
    public string uri { get; set; default = ""; }

    public override void parse() {
        // Get XML from URL and parse result
        base.get_from_uri(uri);

        broadcasts = new Array<Broadcast>();
        Array<string> nodes = base.find_all_keys("item");

        for (var i = 0; i < nodes.length; i++){
            string node = nodes.index(i);
            Broadcast broadcast = new Broadcast();
            broadcast.broadcast_title = node;

            //ToDo: Get Episodes and set them here
            broadcasts.append_val(broadcast);
        }
    }

}
