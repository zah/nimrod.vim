# Nim language support for Vim

This provides [Nim](http://nim-lang.org) language support for Vim:

* Syntax highlighting
* Auto-indent

Use these plugin can autocomplete with lsp
```vim
Plug 'girishji/vimcomplete'
Plug 'yegappan/lsp'

" or download
https://github.com/girishji/vimcomplete
https://github.com/yegappan/lsp
```

```nimble nimlsp``` 
```vim
" add setting to .vimrc
au filetype nim call LspAddServer([#{
            \    name: 'nimlsp',
            \    filetype: ['nim'],
            \    path: 'nimlsp',
            \  }])
```
You can see [vimcomplete](https://github.com/girishji/vimcomplete
) helps when you want more configure
