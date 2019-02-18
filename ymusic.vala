/*
 * Webkit2gtk is a port of the webkit2 widget to Gtk. With it you can embed a
 * browser into your project.
 * Compile using:
 * valac webkit2.vala --pkg gtk+-3.0 --pkg webkit2gtk-4.0
 *
 * Based on https://wiki.gnome.org/Projects/Vala/WebKitSample
 * WebKit documentation https://valadoc.org/webkit2gtk-4.0/index.htm
 *
 * Make sure you have installed the package libwebkit2gtk-4.0-dev in debian or
 * derivative systems
 * $ apt-get install libwebkit2gtk-4.0-dev
 *
 * Author: Geronimo Bareiro https://github.com/gerito1
*/

using Gtk;
using WebKit;

public class MyWebkitWindow : Gtk.Window {

    private const string BROWSER_TITLE = "Youtube Music";

    private WebKit.WebView web_view; //This is the widget that shows the page
    public MyWebkitWindow () {}

    /* Using GObject-Style construction
     * See https://chebizarro.gitbooks.io/the-vala-tutorial/content/gobject-style-construction.html
     */
    construct {
        title = MyWebkitWindow.BROWSER_TITLE;
        set_default_size (500, 500);

        web_view = new WebKit.WebView ();
        CookieManager cookiemanager = web_view.get_context().get_cookie_manager();
        cookiemanager.set_accept_policy(CookieAcceptPolicy.ALWAYS);
        cookiemanager.set_persistent_storage("/tmp/ymusic", CookiePersistentStorage.TEXT);

        web_view.load_uri ("http://music.youtube.com");

        var scrolled_window = new Gtk.ScrolledWindow (null, null); //The WebView doesn't contain scroll bars by its own.
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrolled_window.add (web_view);
        scrolled_window.hexpand = true;
        scrolled_window.vexpand = true;

        var grid = new Gtk.Grid ();
        grid.attach (scrolled_window, 0, 0, 1, 1);
        add (grid as Gtk.Widget);
        show_all ();
    }

        public static int main (string[] args) {
        Gtk.init (ref args);
        //Gtk.show_uri_on_window(null, "http://www.tv2.dk",1);

        var my_webkit_window = new MyWebkitWindow ();

        Gtk.main ();

        return 0;
    }

}
