#!/bin/bash
rm postcix
cd src
valac --pkg gtk+-3.0 --pkg gdk-3.0 --pkg libpq --pkg gtksourceview-3.0 main.vala io.vala favorite_view.vala host_item.vala setting.vala database_view.vala database_item.vala map.vala treeview_enum.vala image_manager.vala postgres.vala -X -lpq -o ../postcix
cd ..

./postcix 2> /dev/null
