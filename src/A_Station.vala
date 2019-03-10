public abstract class A_Station:GLib.Object{
    public E_StationNames name { public get; private set; }
    private string rpc_url = "https://srv.deutschlandradio.de/aodpreviewdata.1915.de.rpc?";
    public Preview preview { public get; protected set; }

    protected A_Station(E_StationNames station_name){
        name = station_name;
        this.preview = new Preview();

    }

    public string get_stream_url(){
        return "https://dg-dradio-https-fra-dtag-cdn.sslcast.addradio.de/dradio/"
        +name.to_string()+"/live/mp3/128/stream.mp3";
    }

    public void get_live_program(){
        int id = name;
        string uri = rpc_url+"drbm:station_id="+id.to_string();
        preview.uri = uri;
        preview.parse();
        preview.cleanup();
    }


    public Array<Podcast> get_podcasts(){
        return new Array<Podcast>();
    }

}

