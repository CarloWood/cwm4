# Using a cwm4 submodule

The root project should be using
[autotools](https://en.wikipedia.org/wiki/GNU_Build_System_autotools) or
[cmake](https://cmake.org/), and
[cwm4](https://github.com/CarloWood/cwm4) and
[cwds](https://github.com/CarloWood/cwds).

## Checking out a project that uses the cwm4 submodule.

To clone a project <tt>example-project</tt> that uses cwm4 submodule(s) simply clone the project using `--recursive` and then run `./autogen.sh`:

    git clone --recursive <URL-to-project>/example-project.git
    cd example-project
    ./autogen.sh

If you forget to use <tt>--recursive</tt> then <tt>./autogen.sh</tt> will fix that.

Afterwards, if you are using autotools, you probably want to use <tt>--enable-mainainer-mode</tt>
as option to the generated <tt>configure</tt> script.

## Adding a cwm4 submodule to your project

To add a submodule <i>XYZ</i> to a project, that project should already
be set up to use [cwm4](https://github.com/CarloWood/cwm4).

Simply execute the following in a directory of that project
where you want to have the `XYZ` subdirectory:

    git submodule add https://github.com/CarloWood/XYZ.git

This should clone <i>XYZ</i> into the subdirectory `XYZ`, or
if you already cloned it there, it should add it.

Note that if <i>XYZ</i> starts with <tt>ai-</tt> then the required
subdirectory that it is cloned into needs to have that prefix removed.
Currently those submodules are <tt>ai-utils</tt>,
<tt>ai-statefultask</tt> and <tt>ai-xml</tt>. For example to add
the submodule <tt>ai-utils</tt> to a project, execute the following
in the root of the project:

    git submodule add https://github.com/CarloWood/ai-utils.git utils

### Using cmake

When using cmake you probably want to set the environment variable,

    AUTOGEN_CMAKE_ONLY=1

prior to running `./autogen.sh`. This will skip any GNU autotools
initialization.

For most projects you probably also want to enable [gitache](https://github.com/CarloWood/gitache).
That project is self-installing and only requires that you set
another environment variable, pointing to a (large) directory that
you have write access too. For example,

    export GITACHE_ROOT="/opt/gitache"

where `/opt/gitache` is owned by you.

The typical `CMakeLists.txt` file, containing a single executable,
would look like

    include(AICxxProject)

    add_executable(some_test some_test.cxx)
    target_link_libraries(some_test PRIVATE ${AICXX_OBJECTS_LIST})

That is, `AICXX_OBJECTS_LIST` is, automatically, filled with all the
objects of all the aicxx submodules. Alternatively, you can list all
required aicxx submodules manually. For example,

    add_executable(some_test some_test.cxx)
    target_link_libraries(some_test PRIVATE AICxx::statefultask AICxx::evio AICxx::evio_protocol AICxx::threadpool AICxx::threadsafe AICxx::events AICxx::xml AICxx::math AICxx::utils AICxx::cwds)

For the largest part the order of these is important as many depend on what is on their right-side.

### Using GNU autotools

Changes to `configure.ac` and `Makefile.am`
are taken care of by `cwm4`, except for linking
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
