let g:nimrod_log = []
let s:plugin_path = escape(expand('<sfile>:p:h'), ' \')

if !exists("g:nimrod_caas_enabled")
  let g:nimrod_caas_enabled = 1
endif

if !executable('nimrod')
  echoerr "the nimrod compiler must be in your system's PATH"
endif

exe 'pyfile ' . fnameescape(s:plugin_path) . '/nimrod_vim.py'

fun! nimrod#init()
  let cmd = printf("nimrod --dump.format:json --verbosity:0 dump %s", s:CurrentNimrodFile())
  let raw_dumpdata = system(cmd)
  if !v:shell_error
    let dumpdata = eval(substitute(raw_dumpdata, "\n", "", "g"))
    
    let b:nimrod_project_root = dumpdata['project_path']
    let b:nimrod_defined_symbols = dumpdata['defined_symbols']
    let b:nimrod_caas_enabled = g:nimrod_caas_enabled || index(dumpdata['defined_symbols'], 'forcecaas') != -1

    for path in dumpdata['lib_paths']
      if finddir(path) == path
        let &l:path = path . "," . &l:path
      endif
    endfor
  else
    let b:nimrod_caas_enabled = 0
  endif
endf

fun! s:UpdateNimLog()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile

  for entry in g:nimrod_log
    call append(line('$'), split(entry, "\n"))
  endfor

  let g:nimrod_log = []

  match Search /^nimrod\ .*/
endf

augroup NimrodVim
  au!
  au BufEnter log://nimrod call s:UpdateNimLog()
  au QuitPre * :py nimTerminateAll()
  au VimLeavePre * :py nimTerminateAll()
augroup END

command! NimLog :e log://nimrod

command! NimTerminateService
  \ :exe printf("py nimTerminateService('%s')", b:nimrod_project_root)

command! NimRestartService
  \ :exe printf("py nimRestartService('%s')", b:nimrod_project_root)

fun! s:CurrentNimrodFile()
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
  let cmd = printf("idetools %s --track:\"%s,%d,%d\" \"%s\"",
    \ a:op, expand('%:p'), line('.'), col('.')-1, s:CurrentNimrodFile())

  if b:nimrod_caas_enabled
    exe printf("py nimExecCmd('%s', '%s', False)", b:nimrod_project_root, cmd)
    let output = l:py_res
  else
    let output = system("nimrod " . cmd)
  endif

  call add(g:nimrod_log, "nimrod " . cmd . "\n" . output)
  return output
endf

fun! NimExecAsync(op, Handler)
  let result = NimExec(a:op)
  call a:Handler(result)
endf

fun! NimComplete(findstart, base)
  if b:nimrod_caas_enabled == 0
    return -1
  endif

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
      if len(lineData) > 0 && lineData[0] == "sug"
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

let g:neocomplcache_omni_patterns['nimrod'] = '[^. *\t]\.\w*'
let g:nimrod_completion_callbacks = {}

fun! NimrodAsyncCmdComplete(cmd, output)
  call add(g:nimrod_log, a:output)
  echom g:nimrod_completion_callbacks
  if has_key(g:nimrod_completion_callbacks, a:cmd)
    let Callback = get(g:nimrod_completion_callbacks, a:cmd)
    call Callback(a:output)
    " remove(g:nimrod_completion_callbacks, a:cmd)
  else
    echom "ERROR, Unknown Command: " . a:cmd
  endif
  return 1
endf

fun! GotoDefinition_nimrod_ready(def_output)
  if v:shell_error
    echo "nimrod was unable to locate the definition. exit code: " . v:shell_error
    " echoerr a:def_output
    return 0
  endif
  
  let rawDef = matchstr(a:def_output, 'def\t\([^\n]*\)')
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

fun! GotoDefinition_nimrod()
  call NimExecAsync("--def", function("GotoDefinition_nimrod_ready"))
endf

fun! FindReferences_nimrod()
  setloclist()
endf

" Syntastic syntax checking
fun! SyntaxCheckers_nimrod_GetLocList()
  let makeprg = 'nimrod check ' . s:CurrentNimrodFile()
  let errorformat = &errorformat
  
  return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endf

