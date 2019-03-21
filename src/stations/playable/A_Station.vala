public abstract class A_Station: I_Playable, GLib.Object{
    public E_StationNames? name { public get; private set; }
    public Preview preview { public get; protected set; }

    private string rpc_url = "https://srv.deutschlandradio.de/aodpreviewdata.1915.de.rpc?";


    protected A_Station(E_StationNames station_name){
        name = station_name;
        preview = new Preview();
    }

    public string get_stream_url(){
        return "https://dg-dradio-https-fra-dtag-cdn.sslcast.addradio.de/dradio/"
        +name.to_string()+"/live/mp3/128/stream.mp3";
    }

    public void parse_xml(){
        int id = name;
        string uri = rpc_url+"drbm:station_id="+id.to_string();
        preview.uri = uri;
        preview.parse();
        preview.cleanup();
    }

    public string get_name(){
        return preview.name;
    }

    public string get_parent_name(){
        return name.get_long_name();
    }

    public Array<Podcast> get_podcasts(){
        return new Array<Podcast>();
    }
}

