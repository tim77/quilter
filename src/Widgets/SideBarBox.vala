/*
* Copyright (c) 2018 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
namespace Quilter.Widgets {
    public class SideBarBox : Gtk.ListBoxRow {
        public MainWindow win;
        private Gtk.Label file_name_label;
        private Gtk.Label file_label;
        public Gtk.Grid file_grid;
        public EditView ev;

        private string? _path;
        public new string? path {
            owned get {
                return _path;
            }
            set {
                _path = value;
                if (_path == Services.FileManager.get_cache_path ()) {
                    file_name_label.label = "New Document";
                    file_label.label = "New File";
                } else {
                    file_name_label.label = Path.get_basename (_path);
                    file_label.label = path;
                }
            }
        }

        public string title {
            owned get {
                if (path != Services.FileManager.get_cache_path ()) {
                    return file_label.label;
                } else {
                    return "New File";
                }
            }
        }

        public signal void save_as ();

        public SideBarBox (MainWindow win, string? path) {
            this.win = win;
            this.activatable = true;
            this.set_size_request (180,-1);
            this.hexpand = false;
            var sbr_context = this.get_style_context ();
            sbr_context.add_class ("quilter-sidebar-box");

            file_name_label = new Gtk.Label ("");
            file_name_label.halign = Gtk.Align.START;
            file_name_label.hexpand = false;
            file_name_label.ellipsize = Pango.EllipsizeMode.END;
            file_name_label.max_width_chars = 27;
            var fnl_context = file_name_label.get_style_context ();
            fnl_context.add_class (Granite.STYLE_CLASS_H3_LABEL);

            file_label = new Gtk.Label ("");
            file_label.halign = Gtk.Align.START;
            file_label.ellipsize = Pango.EllipsizeMode.START;
            file_label.max_width_chars = 25;
            file_label.hexpand = false;

            var file_icon = new Gtk.Image.from_icon_name ("text-markdown", Gtk.IconSize.LARGE_TOOLBAR);

            var file_remove_button = new Gtk.Button();
            var file_remove_button_c = file_remove_button.get_style_context ();
            file_remove_button_c.add_class ("flat");
            file_remove_button_c.add_class ("quilter-task-button");
            file_remove_button_c.add_class ("color-button");
            file_remove_button.has_focus = false;
            file_remove_button.has_tooltip = true;
            file_remove_button.valign = Gtk.Align.CENTER;
            file_remove_button.hexpand = true;
            file_remove_button.set_size_request (24,24);
            file_remove_button.halign = Gtk.Align.END;
            file_remove_button.set_image (new Gtk.Image.from_icon_name ("window-close-symbolic",Gtk.IconSize.BUTTON));
            file_remove_button.tooltip_text = (_("Remove File"));

            file_grid = new Gtk.Grid ();
            file_grid.hexpand = false;
            file_grid.row_spacing = 3;
            file_grid.column_spacing = 6;
            file_grid.margin = 6;
            file_grid.attach (file_icon, 0, 0, 1, 2);
            file_grid.attach (file_name_label, 1, 0, 1, 1);
            file_grid.attach (file_label, 1, 1, 1, 1);
            file_grid.attach (file_remove_button, 2, 0, 1, 2);

            file_remove_button.clicked.connect (() => {
                var dialog = new Services.DialogUtils.Dialog2 ();
                dialog.transient_for = win;
                dialog.response.connect ((response_id) => {
                    switch (response_id) {
                        case Gtk.ResponseType.OK:
                            debug ("User saves the file.");
                            save_as ();
                            delete_row ();
                            dialog.close ();
                            win.edit_view_content.buffer.text = "";
                            win.edit_view_content.buffer.set_modified (false);
                            Services.FileManager.file = null;
                            win.toolbar.set_subtitle (_("No Documents Open"));
                            Widgets.SideBar.get_instance ().store.clear ();
                            break;
                        case Gtk.ResponseType.NO:
                            delete_row ();
                            dialog.close ();
                            win.edit_view_content.buffer.text = "";
                            win.edit_view_content.buffer.set_modified (false);
                            Services.FileManager.file = null;
                            win.toolbar.set_subtitle (_("No Documents Open"));
                            Widgets.SideBar.get_instance ().store.clear ();
                            break;
                        case Gtk.ResponseType.CANCEL:
                        case Gtk.ResponseType.CLOSE:
                        case Gtk.ResponseType.DELETE_EVENT:
                            dialog.close ();
                            break;
                        default:
                            assert_not_reached ();
                    }
                });
                if (win.edit_view_content.buffer.get_modified () == true) {
                    dialog.run ();
                } else if (win.edit_view_content.buffer.get_modified () == false) {
                    delete_row ();
                    win.edit_view_content.buffer.text = "";
                    Services.FileManager.file = null;
                    win.toolbar.set_subtitle (_("No Documents Open"));
                }
            });

            this.add (file_grid);
            this.hexpand = true;
            this.show_all ();
            this.path = path;
        }
        public void delete_row () {
            this.destroy ();
        }
    }
}
