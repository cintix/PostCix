#!/bin/bash
cd src
valac --pkg gtk+-3.0 --pkg gtk+-3.0 --pkg gdk-3.0 --pkg libpq main.vala host_item.vala setting.vala database_view.vala postgres.vala -X -lpq -o ../postcix
cd ..

./postcix 2> /dev/null
