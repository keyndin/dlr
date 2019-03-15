public class Broadcast:GLib.Object, I_Playable{
    public int broadcast_id;
    public string broadcast_url;
    public int broadcast_duration;
    public int broadcast_timestamp; //ToDo: DateTime from_unix_utc(broadcast_timestamp)
    public string broadcast_description;
    public string broadcast_author;
    public int podcast_id;

    public string get_stream_url(){
        return broadcast_url;
    }

    public void get_program_name(){

    }

    public string get_name(){
        return broadcast_description;
    }

    public string get_parent_name(){
        return "Podcastname";
    }
}
