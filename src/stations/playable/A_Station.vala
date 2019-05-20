public abstract class A_Station: I_Playable, GLib.Object{
    public E_StationNames? name { public get; private set; }
    //public LiveRadioInfo live_radio_info { public get; protected set; }
    public BroadcastParser broadcast_parser { public get; protected set; }
    public LiveRadioInfoJsonParser live_json { public get; protected set; }

    private string rpc_url = "https://srv.deutschlandradio.de/aodpreviewdata.1915.de.rpc?";
    private string broadcast_url = "https://srv.deutschlandradio.de/aodpreviewdata.1707.de.rpc?";

    protected A_Station(E_StationNames station_name){
        name = station_name;
        //live_radio_info = new LiveRadioInfo();
        live_json = new LiveRadioInfoJsonParser();
        broadcast_parser =  new BroadcastParser();
    }

    public string get_stream_url(){
        return "https://dg-dradio-https-fra-dtag-cdn.sslcast.addradio.de/dradio/"
        +name.to_string()+"/live/mp3/128/stream.mp3";
    }

    public void set_preview(){
        int id = name;
        string uri = rpc_url+"drbm:station_id="+id.to_string();
        //live_radio_info.uri = uri;
        //live_radio_info.parse();
        //live_radio_info.cleanup();

        live_json.uri = uri;
        live_json.parse();
    }

    public string get_program_name(){
        //return live_radio_info.name;
        return live_json.info.name;
    }

    public string get_parent_name(){
        return name.get_long_name();
    }

    public void get_broadcasts(){
        broadcast_parser.uri = broadcast_url+"drbm:station_id="+name.to_string();
        broadcast_parser.parse();
        broadcast_parser.cleanup();
    }
}

