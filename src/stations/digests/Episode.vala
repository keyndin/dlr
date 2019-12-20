public class Episode:GLib.Object, I_Playable{
    public int id;
    public int duration;
    public int timestamp;
    public string description;
    public string author;
    public int broadcast_id;
    private string _name;
    private string _station_name;
    private string _stream_url;

    public  string name {public owned get{
        return _name;
    }}
	public  string station_name {public owned get{
        return _station_name;
    }}
	public  string stream_url {public owned get{
        return _stream_url;
    }}
    public  bool is_broadcast {public get { return false; }}

    public Episode (string name, string station_name, string stream_url) {
        this._name = name;
        this._station_name = station_name;
        this._stream_url = stream_url;
    }

    public void set_preview(){
    }
}
