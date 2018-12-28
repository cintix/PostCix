bin_PROGRAMS = postico

postico_SOURCES = main.vala host_item.vala
postico_CPPFLAGS = $(POSTICO_CFLAGS)
postico_VALAFLAGS = --pkg gtk+-3.0 --pkg gdk-3.0

postico_LDADD = $(POSTICO_LIBS)

-include $(top_srcdir)/git.mk
