using Gst;

public class StreamPlayer:GLib.Object {

    public State state { get; private set;}
    public I_Playable playable {public get; private set;}
    private MainLoop loop = new MainLoop ();
    private dynamic Element player;

    public StreamPlayer() {
    	player = ElementFactory.make ("playbin", "play");
    	player.set_state(State.READY);
    }

    public void play (I_Playable now_playing) {
        if (playable == now_playing)
            // we're already playing this playable,
            // we don't have to do anything
            return;
        playable = now_playing;

        // Set player to accept a new stream
        player.set_state(State.NULL);
        // Set the new stream uri
		player.uri = playable.get_stream_url();

        // Connect our bus
        var bus = player.get_bus ();
        bus.add_watch (0, bus_callback);

        // Set state to playing
        player.set_state(State.PLAYING);
    }

    public void pause () {
    	player.set_state(State.PAUSED);
    }

    public void resume () {
        player.set_state(State.PLAYING);
    }

    public void stop() {
    	loop.quit();
    	state = State.NULL;
    }

    public void set_volume(double value)
    {
        player.volume = value;
    }

    private void foreach_tag (Gst.TagList list, string tag) {
        switch (tag) {
        case "title":
            string tag_string;
            list.get_string (tag, out tag_string);
            break;
        default:
            break;
        }
    }

    private bool bus_callback (Gst.Bus bus, Gst.Message message) {
        switch (message.type) {
        case MessageType.ERROR:
            // Something went wrong
            GLib.Error err;
            string debug;
            message.parse_error (out err, out debug);
            loop.quit();
            break;
        case MessageType.EOS:
            // End of stream
            state = State.PAUSED;
            stdout.printf ("end of stream\n");
            break;
        case MessageType.STATE_CHANGED:
            // State has changed
            Gst.State oldstate;
            Gst.State newstate;
            Gst.State pending;
            message.parse_state_changed (out oldstate, out newstate,
                                         out pending);
            if (newstate == State.PAUSED) {
                        state = State.PAUSED;
            } else if (newstate == State.PLAYING) {
                        state = State.PLAYING;
            }
            break;
        case MessageType.TAG:
            Gst.TagList tag_list;
            message.parse_tag (out tag_list);
            tag_list.foreach ((TagForeachFunc) foreach_tag);
            break;
        default:
            break;
        }
        return true;
    }
}
