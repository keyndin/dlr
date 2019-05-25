public class MainWindow : Gtk.Application {

    public string title {get; private set;}
    private StreamPlayer player = new StreamPlayer();

    // Window elements
    private Gtk.Label now_playing_label;
    private Gtk.Label now_playing_parent;
    private Gtk.Button play_button;
    private Gtk.Dialog about_dialog;
    private Gtk.PopoverMenu popover_fav_menu;
    private Gtk.TreeView broadcasts_tree_view;
    private Gtk.TreeView favorites_tree_view;
    private Gtk.TreeView program_tree_view;
    private Gtk.TreeView episodes_tree_view;

    // Stations
    private DLF dlf = new DLF();
    private Kultur kultur = new Kultur();
    private Nova nova = new Nova();

    public MainWindow () {
        Object(
            application_id: "com.github.keyndin.dlr",
            flags: ApplicationFlags.FLAGS_NONE
        );
        // this.Streamplayer = new StreamPlayer();
    }


    enum broadcast_columns{
        STATION,
        BROADCAST,
        FAVORITE
    }

    enum episode_columns{
        TIMESTAMP,
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

        broadcasts_tree_view.hide();
        episodes_tree_view.hide();
        favorites_tree_view.hide();
        program_tree_view.show();
    }

    [CCode (instance_pos = -1)]
    public void on_novabutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Nova" button gets clicked
        player.play(nova);

        broadcasts_tree_view.hide();
        episodes_tree_view.hide();
        favorites_tree_view.hide();
        program_tree_view.show();
    }

    [CCode (instance_pos = -1)]
    public void on_kulturbutton_clicked(Gtk.Button sender)
    {
        // This function will be called when the "Kultur" button gets clicked
        player.play(kultur);

        broadcasts_tree_view.hide();
        episodes_tree_view.hide();
        favorites_tree_view.hide();
        program_tree_view.show();
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

        episodes_tree_view.hide();
        program_tree_view.hide();
        favorites_tree_view.hide();

        broadcasts_tree_view.show();

        //TODO move the initialisation of tree_view_columns to the initialisation of the tree_view
        if(broadcasts_tree_view.get_columns().length() == 0){
            //mock data for treeview
            var listmodel = new Gtk.ListStore(3, typeof(string), typeof(string), typeof(string));

            broadcasts_tree_view.set_model(listmodel);

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


            Broadcasts_test[] broadcasts_test_data = {
                new Broadcasts_test("DLF", "Am Sonntag Morgen", "Ja"),
                new Broadcasts_test("Nova", "Dein Sonntag", "Nein")
            };

            Gtk.TreeIter iter;
            for(int i = 0; i < broadcasts_test_data.length; i++){
                listmodel.append (out iter);
                listmodel.set(iter
                , broadcast_columns.STATION, broadcasts_test_data[i].station_name
                , broadcast_columns.BROADCAST, broadcasts_test_data[i].broadcast_name
                , broadcast_columns.FAVORITE, broadcasts_test_data[i].favorite_state);
            }
        }
    }


    [CCode (instance_pos = -1)]
    public void on_favorites_button_clicked(Gtk.Button sender){
        var is_popover_open = popover_fav_menu.get_visible();

        if(is_popover_open == true){
            popover_fav_menu.popdown();
        }


        broadcasts_tree_view.hide();
        episodes_tree_view.hide();
        program_tree_view.hide();

        favorites_tree_view.show();

        //TODO move the initialisation of tree_view_columns to the initialisation of the tree_view
        if(favorites_tree_view.get_columns().length() == 0){

            //mock data for treeview
            var listmodel = new Gtk.ListStore(3, typeof(string), typeof(string), typeof(string));

            favorites_tree_view.set_model(listmodel);

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


            Broadcasts_test[] broadcasts_test_data = {
                new Broadcasts_test("DLF", "Am Sonntag Morgen", "Ja"),
                new Broadcasts_test("Nova", "Dein Sonntag", "Nein")
            };

            Gtk.TreeIter iter;
            for(int i = 0; i < broadcasts_test_data.length; i++){
                listmodel.append (out iter);
                listmodel.set(iter
                , broadcast_columns.STATION, broadcasts_test_data[i].station_name
                , broadcast_columns.BROADCAST, broadcasts_test_data[i].broadcast_name
                , broadcast_columns.FAVORITE, broadcasts_test_data[i].favorite_state);
            }
        }
    }

    [CCode (instance_pos = -1)]
    public void on_broadcasts_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        //index in broadcast array
        //print(path.to_string());
        //clicked column (for check on favorite)
        //print(column.title);

        //hides other tree_views and displays the episodes_tree_view
        broadcasts_tree_view.hide();
        favorites_tree_view.hide();
        program_tree_view.hide();

        episodes_tree_view.show();


        if(episodes_tree_view.get_columns().length() == 0){

            //mock data for treeview
            var listmodel = new Gtk.ListStore(5
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string));

            episodes_tree_view.set_model(listmodel);

            episodes_tree_view.insert_column_with_attributes(-1
            ,"Datum/Uhrzeit"
            , new Gtk.CellRendererText()
            , "text"
            , episode_columns.TIMESTAMP);

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


            Episodes_test[] episodes_test_data = {
                new Episodes_test("25.05.2019 18:42", "Am Sonntag Morgen", "Abends um 18 Uhr", "Heinz", "4:34 min"),
                new Episodes_test("25.05.2019 19:42", "Dein Sonntag", "Sonntags abend 19:42", "Eick", "3:12 min")
            };

            Gtk.TreeIter iter;
            for(int i = 0; i < episodes_test_data.length; i++){
                listmodel.append (out iter);
                listmodel.set(iter
                , episode_columns.TIMESTAMP, episodes_test_data[i].timestamp
                , episode_columns.BROADCAST, episodes_test_data[i].broadcast_name
                , episode_columns.EPISODE, episodes_test_data[i].episode_name
                , episode_columns.AUTHOR, episodes_test_data[i].author
                , episode_columns.DURATION, episodes_test_data[i].duration);
            }
        }
    }

    [CCode (instance_pos = -1)]
    public void on_favorites_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        broadcasts_tree_view.hide();
        favorites_tree_view.hide();
        episodes_tree_view.hide();
        program_tree_view.show();

         if(program_tree_view.get_columns().length() == 0){

            //mock data for treeview
            var listmodel = new Gtk.ListStore(5
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string));

            program_tree_view.set_model(listmodel);

            program_tree_view.insert_column_with_attributes(-1
            ,"Datum/Uhrzeit"
            , new Gtk.CellRendererText()
            , "text"
            , episode_columns.TIMESTAMP);

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


            Episodes_test[] episodes_test_data = {
                new Episodes_test("25.05.2019 18:42", "Am Sonntag Morgen", "Abends um 18 Uhr", "Heinz", "4:34 min"),
                new Episodes_test("25.05.2019 19:42", "Dein Sonntag", "Sonntags abend 19:42", "Eick", "3:12 min")
            };

            Gtk.TreeIter iter;
            for(int i = 0; i < episodes_test_data.length; i++){
                listmodel.append (out iter);
                listmodel.set(iter
                , episode_columns.TIMESTAMP, episodes_test_data[i].timestamp
                , episode_columns.BROADCAST, episodes_test_data[i].broadcast_name
                , episode_columns.EPISODE, episodes_test_data[i].episode_name
                , episode_columns.AUTHOR, episodes_test_data[i].author
                , episode_columns.DURATION, episodes_test_data[i].duration);
            }
        }
    }

    [CCode (instance_pos = -1)]
    public void on_episodes_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column){
        //TODO set selected episode as playable for the player
        //index in the episode array
        print(path.to_string());
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
        // This function will be called when the "DLR" button gets clicked
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
    }

    [CCode (instance_pos = -1)]
    public void on_volume_changed(Gtk.ScaleButton sender)
    {
        player.set_volume(sender.value);
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
}

//mock class for treeview
public class Broadcasts_test{
    public string station_name;
    public string broadcast_name;
    public string favorite_state;

    public Broadcasts_test(string station, string broadcast, string favorite){
        this.station_name = station;
        this.broadcast_name = broadcast;
        this.favorite_state = favorite;
    }
}

public class Episodes_test{
    public string timestamp;
    public string broadcast_name;
    public string episode_name;
    public string author;
    public string duration;

    public Episodes_test(string timestamp, string broadcast, string episode, string author, string duration){
        this.timestamp = timestamp;
        this.broadcast_name = broadcast;
        this.episode_name = episode;
        this.author = author;
        this.duration = duration;
    }
}

