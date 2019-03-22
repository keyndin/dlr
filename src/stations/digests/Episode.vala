public class Episode:GLib.Object, I_Playable{
    public int episode_id;
    public string episode_url;
    public int episode_duration;
    public int episode_timestamp; //ToDo: DateTime from_unix_utc(episode_timestamp)
    public string episode_description;
    public string episode_author;
    public int broadcast_id;

    public string get_stream_url(){
        return episode_url;
    }

    public void parse_preview(){
    }

    public string get_name(){
        return episode_description;
    }

    public string get_parent_name(){
        return "Broadcastname";
    }
}
