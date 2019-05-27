public class MainWindow : Gtk.Application {

    public string title {get; private set;}
    private StreamPlayer player = new StreamPlayer();

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
    private DLF dlf = new DLF();
    private Kultur kultur = new Kultur();
    private Nova nova = new Nova();
    private EpisodeQuery episode_query = new EpisodeQuery();

    private Gtk.Scale progress_slider;
    public SchemaIO schema { public get; private set; }

    public MainWindow () {
        Object(
            application_id: "com.github.keyndin.dlr",
            flags: ApplicationFlags.FLAGS_NONE
        );
        schema = new SchemaIO();

        schema.consume_broadcasts(dlf);
        schema.consume_broadcasts(kultur);
        schema.consume_broadcasts(nova);
    }

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

    // Since Vala compiles to C, we want our instance variable set last
    [CCode (instance_pos = -1)]
    public void on_dlrbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "DLR" button gets clicked
        player.play(dlf);

        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().show();

        fill_broadcast_tree_view(dlf);

        //get_program for date.now()
        var time = new DateTime.now();
        //TODO second parameter for station
        dlf.daily_episodes(time);
        fill_program_tree_view(dlf);
    }

    [CCode (instance_pos = -1)]
    public void on_novabutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Nova" button gets clicked
        player.play(nova);

        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().show();

        fill_broadcast_tree_view(nova);

        //get_program for date.now()
        var time = new DateTime.now();
        //TODO second parameter for station
        nova.daily_episodes(time);
        fill_program_tree_view(nova);

    }

    [CCode (instance_pos = -1)]
    public void on_kulturbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Kultur" button gets clicked
        player.play(kultur);

        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().show();

        fill_broadcast_tree_view(kultur);

        //get_program for date.now()
        var time = new DateTime.now();
        //TODO second parameter for station
        //episode_query.query_episodes(time.format("%x"));
        kultur.daily_episodes(time);
        fill_program_tree_view(kultur);
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

            switch((string)station_column){
                case "DLR":
                    Broadcast broadcast = dlf.broadcast_parser.broadcasts.index(indices[0]);
                    schema.add_to_favorites(broadcast);
                    break;
                case "Nova":
                    Broadcast broadcast = nova.broadcast_parser.broadcasts.index(indices[0]);
                    schema.add_to_favorites(broadcast);
                    break;
                case "Kultur":
                    Broadcast broadcast = kultur.broadcast_parser.broadcasts.index(indices[0]);
                    schema.add_to_favorites(broadcast);
                    break;
                default:
                    break;
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
        GLib.Value station_column;
        view.get_model().get_value(iter, broadcast_columns.STATION, out station_column);

        switch((string)station_column){
            case "DLR":
                Broadcast broadcast = dlf.broadcast_parser.broadcasts.index(indices[0]);
                fill_episodes_tree_view(dlf, broadcast);
                break;
            case "Nova":
                Broadcast broadcast = nova.broadcast_parser.broadcasts.index(indices[0]);
                fill_episodes_tree_view(nova, broadcast);
                break;
            case "Kultur":
                Broadcast broadcast = kultur.broadcast_parser.broadcasts.index(indices[0]);
                fill_episodes_tree_view(kultur, broadcast);
                break;
            default:
                break;
        }
    }

    [CCode (instance_pos = -1)]
    public void on_favorites_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        //index as int
        int[] indices = path.get_indices();

        broadcasts_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        program_tree_view.get_parent().hide();

        episodes_tree_view.get_parent().show();

        Gtk.TreeIter iter;
        view.get_model().get_iter(out iter, path);
        GLib.Value station_column;
        view.get_model().get_value(iter, broadcast_columns.STATION, out station_column);


        Broadcast broadcast = schema.get_favorites().index(indices[0]);
        // TODO get station name
        switch((string)station_column){
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
        //index as int
        int[] indices = path.get_indices();

        //get associated station
        Gtk.TreeIter iter;
        view.get_model().get_iter(out iter, path);
        GLib.Value station_column;
        view.get_model().get_value(iter, episode_columns.STATION, out station_column);

        switch((string)station_column){
            case "DLR":
                Episode episode = dlf.episode_parser.episodes.index(indices[0]);
                player.play(episode);
                progress_slider.set_range(0, episode.episode_duration);
                resume_progress_slider();
                break;
            case "Nova":
                Episode episode = nova.episode_parser.episodes.index(indices[0]);
                player.play(episode);
                progress_slider.set_range(0, episode.episode_duration);
                resume_progress_slider();
                break;
            case "Kultur":
                Episode episode = kultur.episode_parser.episodes.index(indices[0]);
                player.play(episode);
                progress_slider.set_range(0, episode.episode_duration);
                resume_progress_slider();
                break;
            default:
                break;
        }

    }

    [CCode (instance_pos = -1)]
    public void on_program_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column)
    {
        //index as int
        //int[] indices = path.get_indices();

        //get associated station
        //Gtk.TreeIter iter;
        //view.get_model().get_iter(out iter, path);
        //GLib.Value station_column;
        //view.get_model().get_value(iter, episode_columns.STATION, out station_column);

        //switch((string)station_column){
        //    case "DLR":
        //        Episode episode = dlf.episode_parser.episodes.index(indices[0]);
        //        player.play(episode);
        //       progress_slider.set_range(0, episode.episode_duration);
        //        resume_progress_slider();
        //        break;
        //    case "Nova":
        //        Episode episode = nova.episode_parser.episodes.index(indices[0]);
        //        player.play(episode);
        //        progress_slider.set_range(0, episode.episode_duration);
        //        resume_progress_slider();
        //        break;
        //    case "Kultur":
        //        Episode episode = kultur.episode_parser.episodes.index(indices[0]);
        //        player.play(episode);
        //        progress_slider.set_range(0, episode.episode_duration);
        //        resume_progress_slider();
        //        break;
        //    default:
        //        break;
        }
    }

    private void fill_broadcast_tree_view(A_Station station){
        station.get_broadcasts();

        Array<Broadcast> broadcasts = station.broadcast_parser.broadcasts;

        broadcasts_model.clear();
        //TODO get favorie state;
        Gtk.TreeIter iter;
        for(int i = 0; i < broadcasts.length; i++){
            broadcasts_model.append (out iter);
            broadcasts_model.set(iter
            , broadcast_columns.STATION, station.name.to_display_string()
            , broadcast_columns.BROADCAST, broadcasts.index(i).broadcast_title
            , broadcast_columns.FAVORITE, "Nein");
        }
    }

    private void fill_favorites_tree_view(){
        Array<Broadcast> broadcasts = schema.get_favorites();

        favorites_model.clear();

        //TODO set favorite dynamically
        Gtk.TreeIter iter;
        for(int i = 0; i < broadcasts.length; i++){
            favorites_model.append(out iter);
            favorites_model.set(iter
            , broadcast_columns.STATION, broadcasts.index(i).station_display_name
            , broadcast_columns.BROADCAST, broadcasts.index(i).broadcast_title
            , broadcast_columns.FAVORITE, "Ja");
        }
    }

    private void fill_episodes_tree_view(A_Station station, Broadcast broadcast){
        station.get_episodes(broadcast);
        Array<Episode> episodes = station.episode_parser.episodes;

        episodes_model.clear();

        Gtk.TreeIter iter;
        for(int i = 0; i < episodes.length; i++){

            //Gets DateTime from unix_timestamp
            int64 timestamp = episodes.index(i).episode_timestamp;
            var time = new DateTime.from_unix_utc(timestamp);

            string duration = convert_seconds_to_hh_mm_ss(episodes.index(i).episode_duration);

            episodes_model.append (out iter);
            episodes_model.set(iter
            , episode_columns.TIMESTAMP, time.format("%x  %X")
            , episode_columns.STATION, station.name.to_display_string()
            , episode_columns.BROADCAST, episodes.index(i).broadcast_title
            , episode_columns.EPISODE, episodes.index(i).episode_description
            , episode_columns.AUTHOR, episodes.index(i).episode_author
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

        // TODO: Call search function with entered string
        episode_query.query_episodes(sender.get_text());
        fill_program_tree_view(episode_query);
    }

    private void fill_program_tree_view(A_Station station){
       Array<Episode> episodes = station.episode_parser.episodes;
       program_model.clear();

       Gtk.TreeIter iter;
        for(int i = 0; i < episodes.length; i++){

            //Gets DateTime from unix_timestamp
            int64 timestamp = episodes.index(i).episode_timestamp;
            var time = new DateTime.from_unix_utc(timestamp);

            string duration = convert_seconds_to_hh_mm_ss(episodes.index(i).episode_duration);

            program_model.append (out iter);
            program_model.set(iter
            , episode_columns.TIMESTAMP, time.format("%x  %X")
            , episode_columns.STATION, episodes.index(i).station_display_name
            , episode_columns.BROADCAST, episodes.index(i).broadcast_title
            , episode_columns.EPISODE, episodes.index(i).episode_description
            , episode_columns.AUTHOR, episodes.index(i).episode_author
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
        Gtk.main_quit();
    }

    [CCode (instance_pos = -1)]
    public void on_play_clicked(Gtk.Button sender)
    {
        switch(player.state) {
            case Gst.State.PLAYING:
                player.pause();
                break;
            case Gst.State.PAUSED:
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

    protected override void activate () {
        // Load UI from file
        var builder = new Gtk.Builder.from_resource("/com/github/keyndin/dlr/window.ui");
        builder.connect_signals(this);
        var window = builder.get_object("main_window") as Gtk.Window;
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

        // Connect listeners
        player.notify.connect((s, p) => {
            update_play_button();
        });
        player.playable.notify.connect((s, p) => {
            update_now_playing_label();
        });

        // Update program information pereodicly
        Timeout.add_seconds(15, update_now_playing_label);

        // Run window
        window.show_all();
        program_tree_view.get_parent().hide();
        broadcasts_tree_view.get_parent().hide();
        episodes_tree_view.get_parent().hide();
        favorites_tree_view.get_parent().hide();
        Gtk.main();
    }

    private void update_play_button() {
        // Icon naming convention can be found here:
        // https://developer.gnome.org/icon-naming-spec/
        // TODO: We need a state for stopped
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
            return false;
        player.playable.set_preview();
        now_playing_label.set_label(player.playable.get_program_name());
        now_playing_parent.set_label(player.playable.get_parent_name());
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
        ,"Datum/Uhrzeit (UTC)"
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
        ,"Datum/Uhrzeit (UTC)"
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
    public string format_scale_value(Gtk.Scale sender){
       return (convert_seconds_to_hh_mm_ss((int)sender.get_value()));

    }

    private string convert_seconds_to_hh_mm_ss(int seconds){
        //there is probably a way better way to do this D:
        int format_hours = (seconds / 3600);
        int format_minutes = (seconds / 60) - (3600 * format_hours);
        int format_seconds = (seconds) - (3600 * format_hours) - (60 * format_minutes);

        string min;
        if(format_minutes.to_string().length == 1){
            min = "0" + format_minutes.to_string();
        }
        else{
            min = format_minutes.to_string();
        }

        string sec;
        if(format_seconds.to_string().length == 1){
            sec = "0" + format_seconds.to_string();
        }
        else{
            sec = format_seconds.to_string();
        }

        return format_hours.to_string() + ":" + min +  ":" + sec;
    }
}
