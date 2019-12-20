public abstract class A_Station: I_Playable, GLib.Object{
    // TODO: we should make a lot of these functions async to keep the UI responsive
    private enum request_type {
        RPC=1915,
        BROADCAST=1707,
        SEARCH=1706,
    }

    public int id { public get {
        return program_name.get_id();
    } }
    public E_StationNames program_name { public get; private set; }
    public LiveRadioInfo live_radio_info { public get; protected set; }
    public BroadcastParser broadcast_parser { public get; protected set; }
    public EpisodeParser episode_parser { public get; private set; }

    private const string rpc_url = "https://srv.deutschlandradio.de/aodpreviewdata.%i.de.rpc?%s";
    private const string live_stream_url = "https://dradio-edge-1098-dus-dtag-cdn.sslcast.addradio.de/dradio/%s/live/mp3/128/stream.mp3";
    private const int max_search_limit = 1000;

    private string preview_uri {
        owned get {
            return rpc_url.printf(request_type.RPC, "drbm:station_id=%i".printf(id));
        }
    }
    public string station_name {
        owned get {
            return program_name.get_long_name();
        }
    }
    public string name {
        owned get {
            return live_radio_info.name;
        }
    }

    public string stream_url {
        owned get {
            return live_stream_url.printf(program_name.to_string());
        }
    }

    public bool is_broadcast {
        public get{
            return true;
        }
    }

    protected A_Station(E_StationNames program_name){
        this.program_name = program_name;
        live_radio_info = new LiveRadioInfo(preview_uri);
        broadcast_parser =  new BroadcastParser(program_name);
        episode_parser = new EpisodeParser();
        get_broadcasts();
    }

    public void set_preview(){
        live_radio_info.parse();
        live_radio_info.cleanup();
    }

    public void get_broadcasts(){
        var request = "drbm:station_id=%i".printf(id);
        broadcast_parser.uri = rpc_url.printf(request_type.BROADCAST, request);
        broadcast_parser.parse();
        broadcast_parser.cleanup();
    }

    public void get_episodes(Broadcast broadcast){
        var request = "drau:station_id=%i&drau:broadcast_id=%i".printf(id, broadcast.id);
        episode_parser.uri = rpc_url.printf(request_type.SEARCH, request);
        episode_parser.parse();

        broadcast.episodes = new Array<Episode>();
        var episodes = episode_parser.episodes;

        for(int i = 0; i < episodes.length; i++){
            var episode = episodes.index(i);
            broadcast.episodes.append_val(episode);
        }
        episode_parser.cleanup();
    }

    public void query_episodes(string search_term){
        var request = "drau:searchterm=%s&drau:limit=%i".printf(search_term,max_search_limit);
        episode_parser.uri = rpc_url.printf(request_type.SEARCH, request);
        episode_parser.parse();
        episode_parser.cleanup();
    }

    public void daily_episodes(DateTime date){
        var day = date.format("%x");
        var request = "drau:station_id=%i&drau:from=%s&drau:to=%s&drau:limit=50".printf(id,day,day);
        episode_parser.uri = rpc_url.printf(request_type.SEARCH, request);
        episode_parser.parse();
        episode_parser.cleanup();
    }
}
