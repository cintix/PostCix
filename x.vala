using Gtk;

class mainWindow : Gtk.ApplicationWindow {
  public mainWindow (Application app) {
    this.application = app;
    // Window Properties
    this.set_default_size (800, 600);
    this.window_position = Gtk.WindowPosition.CENTER;
    this.destroy.connect (Gtk.main_quit);

    // HeaderBar
    var headerBar = new Gtk.HeaderBar ();
    headerBar.set_title ("Test Title");
    headerBar.set_subtitle ("Test Subtitle");
    headerBar.set_show_close_button (true);

    // Menu
    var menuButton = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
    headerBar.pack_end (menuButton);

    var menu = new GLib.Menu ();
    menu.append ("Quit", "app.quit");

    var popover = new Gtk.Popover (menuButton);
    popover.bind_model (menu, "app");

    menuButton.clicked.connect (() =>  {
      //popover.popdown ();
      popover.show_all ();
    });

    this.set_titlebar (headerBar);

    this.show_all ();
  }
}

public class Application : Gtk.Application {
  public Application () {
    Object (application_id: "org.example.application", flags: 0);
  }

  protected override void activate () {
    // Create a new window for this application.
    mainWindow win = new mainWindow (this);
    win.show_all ();
    Gtk.main ();
  }

  protected override void startup () {
    base.startup ();

    var quit_action = new GLib.SimpleAction ("app.quit", null);
    quit_action.activate.connect (this.quit);
    this.add_action (quit_action);
  }
}

int main (string[] args) {
    Gtk.init (ref args);
    return new Application ().run (args);
}
