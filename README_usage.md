# Using a cwm4 submodule

The root project should be using
[autotools](https://en.wikipedia.org/wiki/GNU_Build_System_autotools),
[cwm4](/) and
[libcwd](https://github.com/CarloWood/libcwd).

## Checking out a project that uses the cwm4 submodule.

To clone a project example-project that uses cwm4 submodule(s) simply run:

    <b>git clone --recursive</b> &lt;<i>URL-to-project</i>&gt;<b>/example-project.git</b>
    <b>cd example-project</b>
    <b>./autogen.sh</b>

The <tt>--recursive</tt> is optional because <tt>./autogen.sh</tt> will fix
it when you forgot it.

Afterwards you probably want to use <tt>--enable-mainainer-mode</tt>
as option to the generated <tt>configure</tt> script.

## Adding a cwm4 submodule to your project

To add a submodule XYZ to a project, that project should already
be set up to use [cwm4](/).

Simply execute the following in a directory of that project
where you want to have the <tt>XYZ</tt> subdirectory:

    git submodule add https://github.com/CarloWood/XYZ.git

This should clone XYZ into the subdirectory <tt>XYZ</tt>, or
if you already cloned it there, it should add it.

Changes to <tt>configure.ac</tt> and <tt>Makefile.am</tt>
are taken care of by <tt>cwm4</tt>, except for linking
which works as usual;

for example, a module that defines a

    bin_PROGRAMS = foobar

would also define

    foobar_CXXFLAGS = @LIBCWD_R_FLAGS@
    foobar_LDADD = ../XYZ/libXYZ.la $(top_builddir)/cwds/libcwds_r.la

or whatever the path to `XYZ` is, to link with the required submodules,
libraries, and assuming you also use the [cwds](https://github.com/CarloWood/cwds) submodule.

Finally, run

<pre>
./autogen.sh
</pre>

to let cwm4 do its magic, and commit all the changes.
