public class SchemaIO:GLib.Object {
    private Settings settings {private get; private set; }
    public Array<Broadcast> broadcasts { public get; public set; }

    public SchemaIO(){
        broadcasts = new Array<Broadcast>();
        settings = new GLib.Settings ("com.github.keyndin.dlr");
        //settings.reset("favorite-broadcasts");
    }

    public void add_to_favorites(Broadcast broadcast){
        string broadcast_id = broadcast.broadcast_id.to_string();
        string[] ids = settings.get_strv("favorite-broadcasts");
        bool already_faved = check_for_duplicates(broadcast_id);
        if(already_faved) return;
        ids += broadcast_id;
        settings.set_value("favorite-broadcasts", ids);
    }

    public Array<Broadcast> get_favorites(){
        Array<Broadcast> favorites = new Array<Broadcast>();
        string[] ids = settings.get_strv("favorite-broadcasts");
        foreach(string id in ids){
            for(int i = 0; i < broadcasts.length; i++){
                Broadcast broadcast = broadcasts.index(i);
                string broadcast_id = broadcast.broadcast_id.to_string();
                if(id == broadcast_id)
                    favorites.append_val(broadcast);
            }
        }
        return favorites;
    }

    public void remove_from_favorites(Broadcast broadcast){
        string broadcast_id = broadcast.broadcast_id.to_string();
        string[] ids = settings.get_strv("favorite-broadcasts");
        for(int i = 0; i < ids.length; i++){
            var id = ids[i];
            if(id == broadcast_id){
                var index = i;
                for(int j = index; j < ids.length; j++){
                    ids[j] = ids[j+1];
                }
            }
        }
        settings.set_value("favorite-broadcasts", ids);
    }

    public bool check_for_duplicates(string id){
        string[] ids = settings.get_strv("favorite-broadcasts");
        foreach(string val in ids){
            if(val == id) return true;
        }
        return false;
    }

    public void consume_broadcasts(A_Station station){
        var station_broadcasts = station.broadcast_parser.broadcasts;
        for(int i = 0; i < station_broadcasts.length; i++){
            var broadcast = station_broadcasts.index(i);
            broadcasts.append_val(broadcast);
        }
    }
} 