fun! nimrod#init()
endf

let g:nim_log = []

fun! s:UpdateNimLog()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile

  for entry in g:nim_log
    call append(line('$'), split(entry, "\n"))
  endfor

  let g:nim_log = []

  match Search /^nimrod\ idetools.*/
endf

augroup NimLog
  au!
  au BufEnter log://nimrod call s:UpdateNimLog()
augroup END

fun! CurrentNimrodFile()
  let save_cur = getpos('.')
  call cursor(0, 0, 0)
  
  let PATTERN = "\\v^\\#\\s*included from \\zs.*\\ze"
  let l = search(PATTERN, "n")

  if l != 0
    let f = matchstr(getline(l), PATTERN)
    let l:to_check = expand('%:h') . "/" . f
  else
    let l:to_check = expand("%")
  endif

  call setpos('.', save_cur)
  return l:to_check
endf

let g:nimrod_symbol_types = {
  \ 'skParam': 'v',
  \ 'skVar': 'v',
  \ 'skLet': 'v',
  \ 'skTemp': 'v',
  \ 'skForVar': 'v',
  \ 'skConst': 'v',
  \ 'skResult': 'v',
  \ 'skGenericParam': 't',
  \ 'skType': 't',
  \ 'skField': 'm',
  \ 'skProc': 'f',
  \ 'skMethod': 'f',
  \ 'skIterator': 'f',
  \ 'skConverter': 'f',
  \ 'skMacro': 'f',
  \ 'skTemplate': 'f',
  \ 'skEnumField': 'v',
  \ }

fun! NimExec(op)
  let cmd = printf("nimrod idetools %s --track:\"%s,%d,%d\" \"%s\"",
            \ a:op, expand('%:p'), line('.'), col('.')-1, CurrentNimrodFile())

  call add(g:nim_log, cmd)
  let output = system(cmd)
  call add(g:nim_log, output)
  return output
endf

fun! NimComplete(findstart, base)
  if a:findstart
    if synIDattr(synIDtrans(synID(line("."),col("."),1)), "name") == 'Comment'
      return -1
    endif
    return col('.')
  else
    let result = []
    let sugOut = NimExec("--suggest")
    for line in split(sugOut, '\n')
      let lineData = split(line, '\t')
      if lineData[0] == "sug"
        let kind = get(g:nimrod_symbol_types, lineData[1], '')
        let c = { 'word': lineData[2], 'kind': kind, 'menu': lineData[3], 'dup': 1 }
        call add(result, c)
      endif
    endfor
    return result
  endif
endf

if !exists("g:neocomplcache_omni_patterns")
  let g:neocomplcache_omni_patterns = {}
endif

" let g:neocomplcache_omni_patterns['nimrod'] = '[^. *\t]\.\w*'

fun! GotoDefinition_nimrod()
  let defOut = NimExec("--def")
  if v:shell_error
    echo "nimrod was unable to locate the definition. exit code: " . v:shell_error
    " echoerr defOut
    return 0
  endif
  
  let rawDef = matchstr(defOut, 'def\t\([^\n]*\)')
  if rawDef == ""
    echo "the current cursor position does not match any definitions"
    return 0
  endif
  
  let defBits = split(rawDef, '\t')
  let file = defBits[4]
  let line = defBits[5]
  exe printf("e +%d %s", line, file)
  return 1
endf

fun! FindReferences_nimrod()
  setloclist()
endf

" Syntastic syntax checking
fun! SyntaxCheckers_nimrod_GetLocList()
  let makeprg = 'nimrod check ' . CurrentNimrodFile()
  let errorformat = &errorformat
  
  return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endf

