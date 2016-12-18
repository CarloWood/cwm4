SUBDIRS = .

EXTRA_DIST =
BUILT_SOURCES =

distclean-local:

MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

maintainer-clean-local:
	rm -rf html latex

all-local: doxygen.config html.header html.footer
	@echo "doxygen doxygen.config"
	@doxygen doxygen.config
	mkdir -p $(top_builddir)/doc/html/images
	if test -n "`ls $(srcdir)/images/*.png 2>/dev/null`"; then \
	  $(INSTALL) -m 644 $(srcdir)/images/*.png $(top_builddir)/doc/html/images; \
	fi
	mv $(top_builddir)/doc/html/doxygen.png $(top_builddir)/doc/html/images
	test -f $(srcdir)/main.css && $(INSTALL) -m 644 $(srcdir)/main.css $(top_builddir)/doc/html
