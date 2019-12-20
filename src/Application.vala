public class Application : Gtk.Application {
    public static MainWindow window {public get
    {
        if (_window == null) _window = MainWindow.instance;
        return _window;
    }}
    private static MainWindow _window;
    public static Application instance {public get{
        if (_instance == null){
            _instance = new Application();
            MediaKeys.listen();
            SoundIndicator.listen();
        }
        return _instance;
    }}
    private static Application _instance;
    private static bool active = false;

    construct {
        this.flags |= ApplicationFlags.HANDLES_COMMAND_LINE;
        this.application_id = "com.github.keyndin.dlr";
       
    }

    protected override void activate () {

        // calls on_dlrbutton_clicked programatically so that the
        // start view is not so empty ^^
        // TODO: check if this is useful or not
        //  on_dlrbutton_clicked(new Gtk.Button());
        //  player.stop();
        MainWindow.window.present();
        if (!active) {active = !active; Gtk.main();};
    }

    

    public override int command_line(ApplicationCommandLine cmd) {
        string[] args = cmd.get_arguments();
        unowned string[] u_args = args;
        GLib.OptionEntry[] options = new OptionEntry[4];
        
        bool dlr = false, nova = false, kultur = false;

        options[0] = {null};
        options[0] = { "dlr", 0, 0, OptionArg.NONE, ref dlr, "Play dlr", null };
        options[1] = { "nova", 0, 0, OptionArg.NONE, ref nova, "Play nova", null };
        options[2] = { "kultur", 0, 0, OptionArg.NONE, ref kultur, "Play kultur", null };

        var opt_context = new OptionContext ("actions");
        opt_context.add_main_entries (options, null);
        try {
            opt_context.parse (ref u_args);
        } catch (Error err) {
            critical(err.message);
            return -1;
        }

        if (dlr || nova || kultur) {
            if (dlr) window.play_station.begin(window.dlf);
            if (nova) window.play_station.begin(window.nova);;
            if (kultur) window.play_station.begin(window.kultur);;
            window.callback();
        }
        activate();
        return 0;
    }

    public void send_message(string title, string message) {
        var notification = new Notification (title);
        notification.set_body (message);
        send_notification (this.application_id, notification);
    }
}