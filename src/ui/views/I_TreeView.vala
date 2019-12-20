public interface I_TreeView {
    public abstract Gtk.ListStore model {public get;}
    abstract enum columns {STATION,BROADCAST,}
    protected abstract StreamPlayer player {get;} // TODO: do we need this? Or do we want to send signals?
    
    [CCode (instance_pos = -1)]
    public abstract void on_tree_view_row_activated(Gtk.TreeView view, Gtk.TreePath path, Gtk.TreeViewColumn column);
    [CCode (instance_pos = -1)]
    public abstract void fill_tree_view();
}