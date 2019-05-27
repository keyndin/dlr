public abstract class A_Station: I_Playable, GLib.Object{
    public int station_id { public get; private set; }
    public E_StationNames? name { public get; private set; }
    public LiveRadioInfo live_radio_info { public get; protected set; }
    public BroadcastParser broadcast_parser { public get; protected set; }
    public EpisodeParser episode_parser { public get; private set; }

    private string rpc_url = "https://srv.deutschlandradio.de/aodpreviewdata.1915.de.rpc?";
    private string broadcast_url = "https://srv.deutschlandradio.de/aodpreviewdata.1707.de.rpc?";
    private string episode_url = "https://srv.deutschlandradio.de/aodlistaudio.1706.de.rpc?";
    private string search_url = "https://srv.deutschlandradio.de/aodlistaudio.1706.de.rpc?drau:searchterm=";

    protected A_Station(E_StationNames station_name){
        name = station_name;
        station_id = name.get_id();
        live_radio_info = new LiveRadioInfo();
        broadcast_parser =  new BroadcastParser();
        broadcast_parser.station_display_name = name.to_display_string();
        episode_parser = new EpisodeParser();
        get_broadcasts();

    }

    public string get_stream_url(){
        return "https://dg-dradio-https-fra-dtag-cdn.sslcast.addradio.de/dradio/"
        +name.to_string()+"/live/mp3/128/stream.mp3";
    }

    public void set_preview(){
        int id = name;
        string uri = rpc_url+"drbm:station_id="+id.to_string();
        live_radio_info.uri = uri;
        live_radio_info.parse();
        live_radio_info.cleanup();
    }

    public string get_program_name(){
        return live_radio_info.name;
    }

    public string get_parent_name(){
        return name.get_long_name();
    }

    public void get_broadcasts(){
        broadcast_parser.uri = broadcast_url
                               +"drbm:station_id="
                               +station_id.to_string();
        broadcast_parser.parse();
        broadcast_parser.cleanup();
    }

    public void get_episodes(Broadcast broadcast){
        episode_parser.uri = episode_url
                             +"drau:station_id="
                             +station_id.to_string()
                             +"&drau:broadcast_id="
                             +broadcast.broadcast_id.to_string();
        episode_parser.parse();

        broadcast.episodes = new Array<Episode>();
        var episodes = episode_parser.episodes;

        for(int i = 0; i < episodes.length; i++){
            var episode = episodes.index(i);
            episode.station_display_name = name.to_display_string();

            broadcast.episodes.append_val(episode);
        }

        episode_parser.cleanup();
    }

    public void query_episodes(string search_term){
        episode_parser.uri = search_url
                             +search_term
                             +"&drau:limit=1000";
        episode_parser.parse();
        episode_parser.cleanup();
    }
}

