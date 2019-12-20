public class MainWindow : Gtk.Window {
    // TODO: We have to rework a lot of the signal handerls and make a lot of it more generic
    public static MainWindow instance {public get{
        if (_instance == null)
            _instance = new MainWindow();
        return _instance;
    }}
    private static MainWindow _instance;
    public static Gtk.Window window {public get;private set;}
    private StreamPlayer player = StreamPlayer.instance;
    public SourceFunc callback {public get; private set;}

    string cur_title = ""; // remember title of current broadcast

    // Window elements
    private Gtk.Label now_playing_label;
    private Gtk.Label now_playing_parent;
    private Gtk.Button play_button;
    private Gtk.Dialog about_dialog;
    private Gtk.PopoverMenu popover_fav_menu;
    // Tree Views
    private Gtk.TreeView broadcasts_tree_view;
    private Gtk.TreeView favorites_tree_view;
    private Gtk.TreeView program_tree_view;
    private Gtk.TreeView episodes_tree_view;

    private Gtk.ListStore broadcasts_model = new Gtk.ListStore(3
    , typeof(string)
    , typeof(string)
    , typeof(string));

    private Gtk.ListStore favorites_model = new Gtk.ListStore(3
    , typeof(string)
    , typeof(string)
    , typeof(string));

    private Gtk.ListStore episodes_model = new Gtk.ListStore(6
    , typeof(string)
    , typeof(string)
    , typeof(string)
    , typeof(string)
    , typeof(string)
    , typeof(string));

    private Gtk.ListStore program_model = new Gtk.ListStore(6
    , typeof(string)
    , typeof(string)
    , typeof(string)
    , typeof(string)
    , typeof(string)
    , typeof(string));

    // Stations
    public DLF dlf {public get; private set; default = new DLF();}
    public Kultur kultur {public get; private set; default = new Kultur();}
    public Nova nova {public get; private set; default = new Nova();}
    private EpisodeQuery episode_query = new EpisodeQuery();

    private A_Station current_station;
    //ugly boolean to check if the search is currently active D:
    private bool is_search_active;
    //sorry
    private int current_episode_index = -99;

    private Gtk.Scale progress_slider;
    public SchemaIO schema { public get; private set; }

    enum broadcast_columns{
        STATION,
        BROADCAST,
        FAVORITE
    }

    enum episode_columns{
        TIMESTAMP,
        STATION,
        BROADCAST,
        EPISODE,
        AUTHOR,
        DURATION
    }

    private MainWindow() {}

    construct {
        schema = new SchemaIO();

        schema.consume_broadcasts(dlf);
        schema.consume_broadcasts(kultur);
        schema.consume_broadcasts(nova);

        var builder = new Gtk.Builder.from_resource("/com/github/keyndin/dlr/window.ui");
        builder.connect_signals(this);
        window = builder.get_object("main_window") as Gtk.Window;
        play_button = builder.get_object("play_button") as Gtk.Button;
        now_playing_label = builder.get_object("media_playing_title") as Gtk.Label;
        now_playing_parent = builder.get_object("media_playing_station") as Gtk.Label;
        about_dialog = builder.get_object("about_dialog") as Gtk.Dialog;
        popover_fav_menu = builder.get_object("popover_fav_menu") as Gtk.PopoverMenu;
        broadcasts_tree_view = builder.get_object("broadcasts_tree_view") as Gtk.TreeView;
        favorites_tree_view = builder.get_object("favorites_tree_view") as Gtk.TreeView;
        program_tree_view = builder.get_object("program_tree_view") as Gtk.TreeView;
        episodes_tree_view = builder.get_object("episodes_tree_view") as Gtk.TreeView;

        initialize_tree_views();

        progress_slider = builder.get_object("progress_slider") as Gtk.Scale;

        // Load CSS
        Gtk.CssProvider css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource("/com/github/keyndin/dlr/window.ui.css");
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_USER
        );

        // Set title
        window.title = "Project Aircheck";
        window.application = Application.instance;

        // Connect listeners
        player.state_changed.connect(() => {
            update_play_button();
        });
        player.playable.notify.connect((s, p) => {
            update_now_playing_label();
        });

        // Update program information pereodicly
        Timeout.add_seconds(15, update_now_playing_label);

        // Run window
        program_tree_view.get_parent().hide();
        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();

        window.present();
    }    

    public async void play_station(A_Station current_station){
        // Plays current stations and parses required data to fill programm view
        callback = play_station.callback;
        this.current_station = current_station;

        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        is_search_active = false;
        player.play(current_station);
        current_episode_index = -99;
        progress_slider.set_range(-1, -1);
        ThreadFunc<bool> run = () => {
            // TODO: This is really hacky and has a lot of drawbacks...
            var time = new DateTime.now(new TimeZone.local());
            fill_broadcast_tree_view(current_station);
            current_station.daily_episodes(time);
            fill_program_tree_view(current_station);
            program_tree_view.get_parent().show();
         return true;
        };
        new Thread<bool>("change-station-thread", run);
        yield;
    }

    // Since Vala compiles to C, we want our instance variable set last
    [CCode (instance_pos = -1)]
    public void on_dlrbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked

        //  current_station = dlf;
        play_station.begin(dlf);
        callback();
    }

    [CCode (instance_pos = -1)]
    public void on_novabutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked

        //  current_station = nova;
        play_station.begin(nova);
        callback();
    }

    [CCode (instance_pos = -1)]
    public void on_kulturbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked

        //  current_station = kultur;
        play_station.begin(kultur);
        callback();
    }


    [CCode (instance_pos = -1)]
    public void on_open_popover_menu_clicked(Gtk.Button sender)
    {
        //checks if the popover is currently open
        var is_popover_open = popover_fav_menu.get_visible();

        if(is_popover_open == false){
            popover_fav_menu.popup();
        }
        else{
            popover_fav_menu.popdown();
        }
    }

    [CCode (instance_pos = -1)]
    public void on_broadcasts_button_clicked(Gtk.Button sender){

        var is_popover_open = popover_fav_menu.get_visible();

        if(is_popover_open == true){
            popover_fav_menu.popdown();
        }

        episodes_tree_view.get_parent().hide();
        program_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();

        broadcasts_tree_view.get_parent().show();
    }


    [CCode (instance_pos = -1)]
    public void on_favorites_button_clicked(Gtk.Button sender){
        var is_popover_open = popover_fav_menu.get_visible();

        if(is_popover_open == true){
            popover_fav_menu.popdown();
        }

        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        program_tree_view.get_parent().hide();

        favorites_tree_view.get_parent().show();

        fill_favorites_tree_view();
    }

    [CCode (instance_pos = -1)]
    public void on_broadcasts_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        //index as int
        int[] indices = path.get_indices();

        //clicked column (for check on favorite toggle)
        if(column.title == "Favorit"){
            //gets associated station
            Gtk.TreeIter iter;
            view.get_model().get_iter(out iter, path);
            GLib.Value station_column;
            view.get_model().get_value(iter, broadcast_columns.STATION, out station_column);

            GLib.Value favorite_column;
            view.get_model().get_value(iter, broadcast_columns.FAVORITE, out favorite_column);

            //toggles favorite state
            bool is_favorite = favorite_column == "Ja" ? true : false;
            broadcasts_model.set_value(iter, broadcast_columns.FAVORITE, is_favorite ? "Nein" : "Ja");
            

            Broadcast broadcast;
            switch((string)station_column){
                case "DLR":
                    broadcast = dlf.broadcast_parser.broadcasts.index(indices[0]);
                    break;
                case "Nova":
                    broadcast = nova.broadcast_parser.broadcasts.index(indices[0]);
                    break;
                case "Kultur":
                    broadcast = kultur.broadcast_parser.broadcasts.index(indices[0]);
                    break;
                default:
                    broadcast = dlf.broadcast_parser.broadcasts.index(indices[0]);
                    break;
            }

            warning(broadcast.station);

            if(is_favorite == true){
                schema.remove_from_favorites(broadcast);
            }
            else{
                schema.add_to_favorites(broadcast);
            }
            return;
        }

        //hides other tree_views and displays the episodes_tree_view
        broadcasts_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().hide();

        episodes_tree_view.get_parent().show();

        //gets associated station
        Gtk.TreeIter iter;
        view.get_model().get_iter(out iter, path);
        Broadcast broadcast = current_station.broadcast_parser.broadcasts.index(indices[0]);
        fill_episodes_tree_view(current_station, broadcast);
        
    }

    [CCode (instance_pos = -1)]
    public void on_favorites_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        //index as int
        int[] indices = path.get_indices();

        Gtk.TreeIter iter;
        view.get_model().get_iter(out iter, path);
        GLib.Value station_column;
        view.get_model().get_value(iter, broadcast_columns.STATION, out station_column);

        Broadcast broadcast = schema.get_favorites().index(indices[0]);

        if(column.title == "Favorit"){

            GLib.Value favorite_column;
            view.get_model().get_value(iter, broadcast_columns.FAVORITE, out favorite_column);

            //removes favorite from favorite list
            if(favorite_column == "Ja"){
                schema.remove_from_favorites(broadcast);
                favorites_model.remove(ref iter);
                fill_broadcast_tree_view(current_station);
            }
            return;
        }

        broadcasts_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().show();

        warning((string)station_column);

        switch((string)station_column){
            // TODO: we should rework this call.... lots of redunancies
            case "DLR":
                fill_episodes_tree_view(dlf, broadcast);
                break;
            case "Nova":
                fill_episodes_tree_view(nova, broadcast);
                break;
            case "Kultur":
                fill_episodes_tree_view(kultur, broadcast);
                break;
            default:
                break;
        }

    }

    [CCode (instance_pos = -1)]
    public void on_episodes_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        // FIXME: Can currently only play episodes of the same station that is already playing!
        //index as int
        int[] indices = path.get_indices();
        current_episode_index = indices[0];
        Gtk.TreeIter iter;
        GLib.Value station;
        view.get_model().get_iter(out iter, path);
        view.get_model().get_value(iter, episode_columns.STATION, out station);
        Episode episode;
        switch((string)station){
            case "DLR":
                episode = dlf.episode_parser.episodes.index(indices[0]);
                break;
            case "Nova":
                episode = nova.episode_parser.episodes.index(indices[0]);
                break;
            case "Kultur":
                episode = kultur.episode_parser.episodes.index(indices[0]);
                break;
            default:
                assert_not_reached();
        }
        player.play(episode);
        progress_slider.set_range(0, episode.duration);
        resume_progress_slider();
    }

    [CCode (instance_pos = -1)]
    public void on_program_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column)
    {
        //index as int
        int[] indices = path.get_indices();
        current_episode_index = indices[0];
        //get associated station
        Gtk.TreeIter iter;
        view.get_model().get_iter(out iter, path);
        GLib.Value station_column;
        view.get_model().get_value(iter, episode_columns.STATION, out station_column);

        if(is_search_active == true){
            Episode episode = episode_query.episode_parser.episodes.index(indices[0]);
            player.play(episode);
            progress_slider.set_range(0, episode.duration);
            resume_progress_slider();
        }
        else{
            Episode episode = current_station.episode_parser.episodes.index(indices[0]);
            player.play(episode);
            progress_slider.set_range(0, episode.duration);
            resume_progress_slider();
        }
    }

    private void fill_broadcast_tree_view(A_Station station){
        station.get_broadcasts();

        Array<Broadcast> broadcasts = station.broadcast_parser.broadcasts;

        broadcasts_model.clear();

        Gtk.TreeIter iter;
        for(int i = 0; i < broadcasts.length; i++){
            //checks whether a podcast is already_faved
            bool is_favorite = schema.check_for_duplicates(broadcasts.index(i).id.to_string());

            broadcasts_model.append (out iter);
            broadcasts_model.set(iter
            , broadcast_columns.STATION, current_station.program_name.to_display_string()
            , broadcast_columns.BROADCAST, broadcasts.index(i).title
            , broadcast_columns.FAVORITE, is_favorite ? "Ja" : "Nein");
        }
    }

    private void fill_favorites_tree_view(){
        Array<Broadcast> broadcasts = schema.get_favorites();

        favorites_model.clear();

        Gtk.TreeIter iter;
        for(int i = 0; i < broadcasts.length; i++){
            favorites_model.append(out iter);
            favorites_model.set(iter
            , broadcast_columns.STATION, broadcasts.index(i).station
            , broadcast_columns.BROADCAST, broadcasts.index(i).title
            , broadcast_columns.FAVORITE, "Ja");
        }
    }

    private void fill_episodes_tree_view(A_Station station, Broadcast broadcast){
        station.get_episodes(broadcast);
        Array<Episode> episodes = station.episode_parser.episodes;

        episodes_model.clear();
        current_episode_index = -99;
        Gtk.TreeIter iter;
        for(int i = 0; i < episodes.length; i++){

            //Gets DateTime from unix_timestamp
            int64 timestamp = episodes.index(i).timestamp;
            var time = new DateTime.from_unix_local(timestamp);

            string duration = convert_seconds_to_hh_mm_ss(episodes.index(i).duration);

            episodes_model.append (out iter);
            episodes_model.set(iter
            , episode_columns.TIMESTAMP, time.format("%x  %X")
            , episode_columns.STATION, station.station_name
            , episode_columns.BROADCAST, episodes.index(i).name
            , episode_columns.EPISODE, episodes.index(i).description
            , episode_columns.AUTHOR, episodes.index(i).author
            , episode_columns.DURATION, duration);
        }
    }

    [CCode (instance_pos = -1)]
    public void on_searchbar_activate(Gtk.Entry sender){
        // gets entered string
        //print(sender.get_text());
        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().show();

        episode_query.query_episodes(sender.get_text());
        fill_program_tree_view(episode_query);
        current_episode_index = -99;
        is_search_active = true;
    }

    private void fill_program_tree_view(A_Station station){
       Array<Episode> episodes = station.episode_parser.episodes;
       program_model.clear();

       Gtk.TreeIter iter;
        for(int i = 0; i < episodes.length; i++){

            //Gets DateTime from unix_timestamp
            int64 timestamp = episodes.index(i).timestamp;
            var time = new DateTime.from_unix_local(timestamp);

            string duration = convert_seconds_to_hh_mm_ss(episodes.index(i).duration);

            program_model.append (out iter);
            program_model.set(iter
            , episode_columns.TIMESTAMP, time.format("%x  %X")
            , episode_columns.STATION, episodes.index(i).name
            , episode_columns.BROADCAST, episodes.index(i).station_name
            , episode_columns.EPISODE, episodes.index(i).description
            , episode_columns.AUTHOR, episodes.index(i).author
            , episode_columns.DURATION, duration);
        }
    }


    [CCode (instance_pos = -1)]
    public void on_open_about_clicked(Gtk.Button sender)
    {
        about_dialog.run();
        about_dialog.hide();
    }

    [CCode (instance_pos = -1)]
    public void on_destroy(Gtk.Button sender)
    {
        player.stop();
        destroy();
        Gtk.main_quit();
    }

    [CCode (instance_pos = -1)]
    public void on_play_clicked(Gtk.Button sender)
    {
        switch(player.state) {
            case Gst.State.PLAYING:
                //check if live radio
                // TODO: improve this.................
                if(progress_slider.get_value() == -1){
                    player.stop();
                }
                else{
                    player.pause();
                }
                break;
            case Gst.State.PAUSED:
                player.resume();
                break;
            case Gst.State.NULL:
                player.play(current_station);
                player.resume();
                break;
            default:
                break;
        }

        resume_progress_slider();
    }

    private void resume_progress_slider(){
        Timeout.add(1000, get_progress);
    }

    private bool get_progress(){
        if(player.state == Gst.State.PLAYING){
            //set value of the progress to current player position
            progress_slider.set_value(player.get_position());
            return true;
        }
        return false;
    }

    [CCode (instance_pos = -1)]
    public void on_volume_changed(Gtk.ScaleButton sender)
    {
        player.set_volume(sender.value);
    }

    [CCode (instance_pos = -1)]
    public void on_progress_changed(Gtk.Scale sender){
        player.set_progress(sender.get_value());
        resume_progress_slider();
    }

    private void update_play_button() {
        // Icon naming convention can be found here:
        // https://developer.gnome.org/icon-naming-spec/
        switch(player.state) {
            case Gst.State.PLAYING:
                var icon = new Gtk.Image.from_icon_name(
                    "media-playback-pause",
                    Gtk.IconSize.DIALOG);
                play_button.set_image(icon);
                update_now_playing_label();
                break;
            case Gst.State.PAUSED:
                var icon = new Gtk.Image.from_icon_name(
                        "media-playback-start",
                    Gtk.IconSize.DIALOG);
                play_button.set_image(icon);
                break;
            default:
                var icon = new Gtk.Image.from_icon_name(
                    "view-refresh",
                    Gtk.IconSize.DIALOG);
                play_button.set_image(icon);
                update_now_playing_label();
                break;
        }
    }

    private bool update_now_playing_label() {
        if (player.playable == null)
            // We're not playing anything at the moment.
            return false;
        player.playable.set_preview();
        var title = player.title;
        if (title != null && title != cur_title){
            cur_title = title;
            now_playing_label.set_label(title);
            now_playing_parent.set_label(player.playable.station_name);
            Application.instance.send_message("Jetzt laueft", title);
        }
        return true;
    }


    private void initialize_tree_views(){
        //broadcasts_tree_view
        broadcasts_tree_view.set_model(broadcasts_model);
        broadcasts_tree_view.insert_column_with_attributes(-1
        ,"Station"
        , new Gtk.CellRendererText()
        , "text"
        , broadcast_columns.STATION);

        broadcasts_tree_view.insert_column_with_attributes(-1
        , "Sendung"
        , new Gtk.CellRendererText()
        , "text"
        , broadcast_columns.BROADCAST);

        broadcasts_tree_view.insert_column_with_attributes(-1
        , "Favorit"
        , new Gtk.CellRendererText()
        , "text"
        , broadcast_columns.FAVORITE);

        //favories_tree_view
        favorites_tree_view.set_model(favorites_model);
        favorites_tree_view.insert_column_with_attributes(-1
        ,"Station"
        , new Gtk.CellRendererText()
        , "text"
        , broadcast_columns.STATION);

        favorites_tree_view.insert_column_with_attributes(-1
        , "Sendung"
        , new Gtk.CellRendererText()
        , "text"
        , broadcast_columns.BROADCAST);

        favorites_tree_view.insert_column_with_attributes(-1
        , "Favorit"
        , new Gtk.CellRendererText()
        , "text"
        , broadcast_columns.FAVORITE);

        //episodes_tree_view
        episodes_tree_view.set_model(episodes_model);
        episodes_tree_view.insert_column_with_attributes(-1
        ,"Datum/Uhrzeit"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.TIMESTAMP);

        episodes_tree_view.insert_column_with_attributes(-1
        , "Station"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.STATION);

        episodes_tree_view.insert_column_with_attributes(-1
        , "Sendung"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.BROADCAST);

        episodes_tree_view.insert_column_with_attributes(-1
        , "Episode"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.EPISODE);

        episodes_tree_view.insert_column_with_attributes(-1
        , "Autor"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.AUTHOR);

        episodes_tree_view.insert_column_with_attributes(-1
        , "Länge"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.DURATION);

        //program_tree_view
        program_tree_view.set_model(program_model);
        program_tree_view.insert_column_with_attributes(-1
        ,"Datum/Uhrzeit"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.TIMESTAMP);

        program_tree_view.insert_column_with_attributes(-1
        , "Station"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.STATION);

        program_tree_view.insert_column_with_attributes(-1
        , "Sendung"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.BROADCAST);

        program_tree_view.insert_column_with_attributes(-1
        , "Episode"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.EPISODE);

        program_tree_view.insert_column_with_attributes(-1
        , "Autor"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.AUTHOR);

        program_tree_view.insert_column_with_attributes(-1
        , "Länge"
        , new Gtk.CellRendererText()
        , "text"
        , episode_columns.DURATION);
    }


    [CCode (instance_pos = -1)]
    public void on_next_clicked(Gtk.Button sender)
    {
        if(current_episode_index >= 0){
            int nextIndex = current_episode_index + 1;

            if(program_tree_view.get_parent().get_visible() == true){

                Gtk.TreeIter iter;
                program_tree_view.get_selection().get_selected(null,out iter);

                if(is_search_active == true){
                    if(episode_query.episode_parser.episodes.length <= nextIndex){
                        return;
                    }
                    Episode episode = episode_query.episode_parser.episodes.index(nextIndex);
                    player.play(episode);
                    progress_slider.set_range(0, episode.duration);
                    resume_progress_slider();
                }
                else{
                    if(current_station.episode_parser.episodes.length <= nextIndex){
                        return;
                    }
                    Episode episode = current_station.episode_parser.episodes.index(nextIndex);
                    player.play(episode);
                    progress_slider.set_range(0, episode.duration);
                    resume_progress_slider();
                }
                current_episode_index = nextIndex;
                program_tree_view.get_model().iter_next(ref iter);
                program_tree_view.get_selection().select_iter(iter);
            }
            else if(episodes_tree_view.get_parent().get_visible() == true){

                Gtk.TreeIter iter;
                //all episodes in a broadcast have the same station
                episodes_tree_view.get_model().get_iter_from_string(out iter, "0");
                GLib.Value station_column;
                episodes_tree_view.get_model().get_value(iter, episode_columns.STATION, out station_column);



                switch((string)station_column){
                    case "DLR":
                        if(dlf.episode_parser.episodes.length > nextIndex){
                            Episode episode = dlf.episode_parser.episodes.index(nextIndex);
                            player.play(episode);
                            progress_slider.set_range(0, episode.duration);
                            resume_progress_slider();
                            current_episode_index++;
                        }
                        break;
                    case "Nova":
                        if(nova.episode_parser.episodes.length > nextIndex){
                            Episode episode = nova.episode_parser.episodes.index(nextIndex);
                            player.play(episode);
                            progress_slider.set_range(0, episode.duration);
                            resume_progress_slider();
                            current_episode_index++;
                        }
                        break;
                    case "Kultur":
                        if(kultur.episode_parser.episodes.length > nextIndex){
                            Episode episode = kultur.episode_parser.episodes.index(nextIndex);
                            player.play(episode);
                            progress_slider.set_range(0, episode.duration);
                            resume_progress_slider();
                            current_episode_index++;
                        }
                        break;
                    default:
                        break;
                }

                episodes_tree_view.get_selection().get_selected(null,out iter);
                episodes_tree_view.get_model().iter_next(ref iter);
                episodes_tree_view.get_selection().select_iter(iter);
            }
            else{
                return;
            }
        }
        else{
            return;
        }
    }

    [CCode (instance_pos = -1)]
    public void on_previous_clicked(Gtk.Button sender)
    {
        if(current_episode_index >= 0){
            int prevIndex = current_episode_index - 1;

            if(program_tree_view.get_parent().get_visible() == true){

                Gtk.TreeIter iter;
                program_tree_view.get_selection().get_selected(null,out iter);

                if(is_search_active == true){
                    if(0 > prevIndex){
                        return;
                    }
                    Episode episode = episode_query.episode_parser.episodes.index(prevIndex);
                    player.play(episode);
                    progress_slider.set_range(0, episode.duration);
                    resume_progress_slider();
                }
                else{
                    if(0 > prevIndex){
                        return;
                    }
                    Episode episode = current_station.episode_parser.episodes.index(prevIndex);
                    player.play(episode);
                    progress_slider.set_range(0, episode.duration);
                    resume_progress_slider();
                }
                current_episode_index = prevIndex;
                program_tree_view.get_model().iter_previous(ref iter);
                program_tree_view.get_selection().select_iter(iter);
            }

            else if(episodes_tree_view.get_parent().get_visible() == true){
                Gtk.TreeIter iter;
                //all episodes in a broadcast have the same station
                episodes_tree_view.get_model().get_iter_from_string(out iter, "0");
                GLib.Value station_column;
                episodes_tree_view.get_model().get_value(iter, episode_columns.STATION, out station_column);

                switch((string)station_column){
                    case "DLR":
                        if(current_episode_index > 0){
                            Episode episode = dlf.episode_parser.episodes.index(current_episode_index - 1);
                            player.play(episode);
                            progress_slider.set_range(0, episode.duration);
                            resume_progress_slider();
                            current_episode_index--;
                        }
                        break;
                    case "Nova":
                        if(current_episode_index > 0){
                            Episode episode = nova.episode_parser.episodes.index(current_episode_index - 1);
                            player.play(episode);
                            progress_slider.set_range(0, episode.duration);
                            resume_progress_slider();
                            current_episode_index--;
                        }
                        break;
                    case "Kultur":
                        if(current_episode_index > 0){
                            Episode episode = kultur.episode_parser.episodes.index(current_episode_index - 1);
                            player.play(episode);
                            progress_slider.set_range(0, episode.duration);
                            resume_progress_slider();
                            current_episode_index--;
                        }
                        break;
                    default:
                        break;
                }


                episodes_tree_view.get_selection().get_selected(null,out iter);
                episodes_tree_view.get_model().iter_previous(ref iter);
                episodes_tree_view.get_selection().select_iter(iter);
            }
            else{
                return;
            }
        }
        else{
            return;
        }
    }

    [CCode (instance_pos = -1)]
    public string format_scale_value(Gtk.Scale sender){
       if(sender.get_value() == -1){
           return "Live Radio";
       }
       return (convert_seconds_to_hh_mm_ss((int)sender.get_value()));
    }

    public static string convert_seconds_to_hh_mm_ss(int seconds){
        int hours = seconds / 3600;
        seconds %= 3600;
        int minutes = seconds / 60;
        seconds %= 60;

        string min;
        if(minutes.to_string().length == 1){
            min = "0" + minutes.to_string();
        }
        else{
            min = minutes.to_string();
        }

        string sec;
        if(seconds.to_string().length == 1){
            sec = "0" + seconds.to_string();
        }
        else{
            sec = seconds.to_string();
        }
        return hours.to_string() + ":" + min +  ":" + sec;
    }

}
