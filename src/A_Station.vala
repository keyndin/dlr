public abstract class A_Station:GLib.Object{
    private int station_id;
    private string short_name;

    public string get_stream_url(){
        return "https://dg-dradio-https-fra-dtag-cdn.sslcast.addradio.de/dradio/"
        +short_name+"/live/mp3/128/stream.mp3";
    }

    public Array<Podcast> get_podcasts(){
        return new Array<Podcast>();
    }

    protected A_Station(E_StationNames station_name){
        this.station_id = station_name;
        this.short_name = station_name.to_string();
    }
}



