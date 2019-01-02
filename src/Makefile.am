bin_PROGRAMS = postcix

postcix_SOURCES = main.vala host_item.vala
postcix_CPPFLAGS = $(POSTCIX_CFLAGS)
postcix_VALAFLAGS = --pkg gtk+-3.0 --pkg gdk-3.0 --pkg json-glib-1.0

postcix_LDADD = $(POSTCIX_LIBS)

-include $(top_srcdir)/git.mk
