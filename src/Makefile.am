bin_PROGRAMS = postcix

POSTCIX_CFLAGS += -I/usr/include/postgresql
postcix_SOURCES = main.vala favorite_view.vala host_item.vala setting.vala database_view.vala postgres.vala -X -lpq
postcix_CPPFLAGS = -I/usr/include/postgresql $(POSTCIX_CFLAGS) -lpq
postcix_VALAFLAGS = --pkg gtk+-3.0 --pkg gtk+-3.0 --pkg gdk-3.0 --pkg libpg
postcix_LDFLAGS = -I/usr/include/postgresql
postcix_LDADD = $(POSTCIX_LIBS)

-include $(top_srcdir)/git.mk

