public class Broadcast:GLib.Object{
    public int broadcast_id;
    public string broadcast_title;
    public string station_display_name;
    public Array<Episode> episodes { get; set; }
}

