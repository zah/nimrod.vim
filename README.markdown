Nimrod language support for Vim
-------------------------------

This provides [Nimrod](http://nimrod-code.org) language support for Vim:

* Syntax highlighting
* Auto-indent
* Build/jump to errors within Vim
* Project navigation and Jump to Definition (cgats or compiler-assisted
  idetools).

The source of this script comes mainly from
http://www.vim.org/scripts/script.php?script_id=2632, which comes from a
modified python.vim (http://www.vim.org/scripts/script.php?script_id=790).

Installation
------------

Installing `nimrod.vim` is easy but first you need to have the pathogen plugin
installed.  If you already have pathogen working then skip Step 1 and go to
Step 2.

Step 1: Install pathogen.vim
----------------------------

First I'll show you how to install tpope's
[pathogen.vim](https://github.com/tpope/vim-pathogen) so that it's easy to
install `nimrod.vim`.  Do this in your Terminal so that you get the
`pathogen.vim` file and the directories it needs:

    mkdir -p ~/.vim/autoload ~/.vim/bundle; \
    curl -so ~/.vim/autoload/pathogen.vim \
        https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

Next you *need to add this* to your `~/.vimrc`:

    call pathogen#infect()

Step 2: Install nimrod.vim as a pathogen bundle
-----------------------------------------------

You now have pathogen installed and can put `nimrod.vim` into `~/.vim/bundle`
like this:

    cd ~/.vim/bundle
    git clone git://github.com/zah/nimrod.vim.git

Next you *need to add this* to your `~/.vimrc`:

    fun! JumpToDef()
      if exists("*GotoDefinition_" . &filetype)
        call GotoDefinition_{&filetype}()
      else
        exe "norm! \<C-]>"
      endif
    endf
    
    " Jump to tag
    nn <M-g> :call JumpToDef()<cr>
    ino <M-g> <esc>:call JumpToDef()<cr>i

The `JumpToDef` function hooks the `nimrod.vim` plugin to invoke the nimrod
compiler with the appropriate idetools command. Pressing meta+g will then jump
to the definition of the word your cursor is on. This uses the nimrod compiler
instead of ctags, so it works on any nimrod file which is compilable without
requiring you to maintain a database file.

Other recomended Vim plugins
----------------------------

* https://github.com/scrooloose/syntastic (copied bits from its readme)
* https://github.com/Shougo/neocomplcache
