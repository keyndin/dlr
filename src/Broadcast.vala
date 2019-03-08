public class Broadcast:GLib.Object{
    public int broadcast_id;
    public string broadcast_url;
    public int broadcast_duration;
    public int broadcast_timestamp; //ToDo: DateTime from_unix_utc(broadcast_timestamp)
    public string broadcast_description;
    public string broadcast_author;
    public int podcast_id;
}
