public class EpisodesTreeView : I_TreeView {
    public Gtk.ListStore model {
        public get {
            if (_model == null) {
                _model =  new Gtk.ListStore(6
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string)
            , typeof(string));
            }
            return _model;
        }
    }
    private Gtk.ListStore _model;
    enum columns {TIMESTAMP,STATION,BROADCAST,EPISODE,AUTHOR,DURATION}
    
    [CCode (instance_pos = -1)]
    public void on_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        int[] indices = path.get_indices();
        current_episode_index = indices[0];
        Gtk.TreeIter iter;
        GLib.Value station;
        view.get_model().get_iter(out iter, path);
        view.get_model().get_value(iter, columns.STATION, out station);
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
    public void fill_tree_view() {

    }
}