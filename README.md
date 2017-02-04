# cwm4 git submodule

This repository is a git submodule containing
autoconf macros and helper scripts to support
building a project that uses autotools and
git submodules.

## Checking out a project that uses the cwm4 submodule.

To clone a project example-project that uses cwm4 simply run:

<pre>
<b>git clone --recursive</b> &lt;<i>URL-to-project</i>&gt;<b>/example-project.git</b>
<b>cd example-project</b>
<b>./autogen.sh</b>
</pre>

The <tt>--recursive</tt> is optional because <tt>./autogen.sh</tt> will fix
it when you forgot it.

Afterwards you probably want to use <tt>--enable-mainainer-mode</tt>
as option to the generated <tt>configure</tt> script.

## Adding the cwm4 submodule to a project.

To add this submodule to a project, execute the following
in the root of the project:

<pre>
git submodule add https://github.com/CarloWood/cwm4.git
</pre>

This should clone cwm4 into the subdirectory cwm4, or
if you already cloned it there, it should add it.

Next run:

<pre>
cp cwm4/templates/autogen.sh .
./autogen.sh
</pre>

and follow the instructions (if any). If fixing of <tt>configure.ac</tt>
was necessary, run <tt>./autogen.sh</tt> again until all issues are fixed.

Finally add <tt>autogen.sh</tt> to your project:

<pre>
git add autogen.sh
</pre>

And commit your changes.

To add support for another submodule, add a file called 'configure.m4'
to the root of that submodule -- a template for that file can be
found in [cwm4/templates/configure.m4](https://github.com/CarloWood/cwm4/blob/master/templates/configure.m4).
A more complex example can be found in the repository
[ai-xml-testsuite](https://github.com/CarloWood/ai-xml-testsuite) which
uses [this](https://github.com/CarloWood/ai-xml/blob/master/configure.m4) as configure.m4
file of the submodule [ai-xml](https://github.com/CarloWood/ai-xml).

## Cloning this project.

If you make your own clone of cwm4, make sure to set the
environment variables <tt>GIT_COMMITTER_EMAIL</tt> and
<tt>GIT_COMMITTER_NAME</tt> (and likely you also want
to set <tt>GIT_AUTHOR_EMAIL</tt> and <tt>GIT_AUTHOR_NAME</tt>)
and edit <tt>cwm4/templates/autogen.sh</tt> to use the
md5 hash of your <tt>GIT_COMMITTER_EMAIL</tt>.

<pre>
echo "$GIT_COMMITTER_EMAIL" | md5sum
</pre>
