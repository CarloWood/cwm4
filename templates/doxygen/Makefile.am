all-local: doxygen.config html.header html.footer
	@echo "doxygen doxygen.config"
	@doxygen doxygen.config
	mkdir -p $(builddir)/html/images
	if test -n "`ls $(srcdir)/images/*.png 2>/dev/null`"; then \
	  $(INSTALL) -m 644 $(srcdir)/images/*.png $(builddir)/html/images; \
	fi
	if test -e 'html/doxygen.svg'; then \
	  mv html/doxygen.svg $(builddir)/html/images; \
	else \
	  mv html/doxygen.png $(builddir)/html/images; \
	fi
	test -f $(srcdir)/main.css && $(INSTALL) -m 644 $(srcdir)/main.css $(builddir)/html

maintainer-clean-local:
	rm -rf html latex

MAINTAINERCLEANFILES = $(srcdir)/Makefile.in
