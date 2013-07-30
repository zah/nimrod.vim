" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Keep user-supplied options
if !exists("nimrod_highlight_numbers")
  let nimrod_highlight_numbers = 1
endif
if !exists("nimrod_highlight_builtins")
  let nimrod_highlight_builtins = 1
endif
if !exists("nimrod_highlight_exceptions")
  let nimrod_highlight_exceptions = 1
endif
if !exists("nimrod_highlight_space_errors")
  let nimrod_highlight_space_errors = 1
endif

if exists("nimrod_highlight_all")
  let nimrod_highlight_numbers      = 1
  let nimrod_highlight_builtins     = 1
  let nimrod_highlight_exceptions   = 1
  let nimrod_highlight_space_errors = 1
endif

syn region nimrodBrackets       contained extend keepend matchgroup=Bold start=+\(\\\)\@<!\[+ end=+]\|$+ skip=+\\\s*$\|\(\\\)\@<!\\]+ contains=@tclCommandCluster

syn keyword nimrodKeyword       addr and as asm atomic
syn keyword nimrodKeyword       bind block break
syn keyword nimrodKeyword       case cast const continue converter
syn keyword nimrodKeyword       discard distinct div do
syn keyword nimrodKeyword       elif else end enum except export
syn keyword nimrodKeyword       finally for from
syn keyword nimrodKeyword       generic
syn keyword nimrodKeyword       if import in include interface is isnot iterator
syn keyword nimrodKeyword       lambda let
syn keyword nimrodKeyword       mixin mod
syn keyword nimrodKeyword       nil not notin
syn keyword nimrodKeyword       object of or out
syn keyword nimrodKeyword       proc method macro template nextgroup=nimrodFunction skipwhite
syn keyword nimrodKeyword       ptr
syn keyword nimrodKeyword       raise ref return
syn keyword nimrodKeyword       shared shl shr static
syn keyword nimrodKeyword       try tuple type
syn keyword nimrodKeyword       var
syn keyword nimrodKeyword       when while with without
syn keyword nimrodKeyword       xor
syn keyword nimrodKeyword       yield

syn match   nimrodFunction	    "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn match   nimrodClass         "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn keyword nimrodRepeat	      for while
syn keyword nimrodConditional	  if elif else case of
syn keyword nimrodOperator	    and in is not or xor shl shr div
syn match   nimrodComment	      "#.*$" contains=nimrodTodo,@Spell
syn keyword nimrodTodo		      TODO FIXME XXX contained
syn keyword nimrodBoolean       true false


" Strings
syn region nimrodString start=+'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=nimrodEscape,nimrodEscapeError,@Spell
syn region nimrodString start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=nimrodEscape,nimrodEscapeError,@Spell
syn region nimrodString start=+"""+ end=+"""+ keepend contains=nimrodEscape,nimrodEscapeError,@Spell
syn region nimrodRawString matchgroup=Normal start=+[rR]"+ end=+"+ skip=+\\\\\|\\"+ contains=@Spell

syn match  nimrodEscape		+\\[abfnrtv'"\\]+ contained
syn match  nimrodEscape		"\\\o\{1,3}" contained
syn match  nimrodEscape		"\\x\x\{2}" contained
syn match  nimrodEscape		"\(\\u\x\{4}\|\\U\x\{8}\)" contained
syn match  nimrodEscape		"\\$"

syn match nimrodEscapeError "\\x\x\=\X" display contained

if nimrod_highlight_numbers == 1
  " numbers (including longs and complex)
  syn match   nimrodNumber	"\v<0x\x+(\'(i|I|f|F|u|U)(8|16|32|64))?>"
  syn match   nimrodNumber	"\v<[0-9_]+(\'(i|I|f|F|u|U)(8|16|32|64))?>"
  syn match   nimrodNumber	"\v\.[0-9_]+([eE][+-]=[0-9_]+)=>"
  syn match   nimrodNumber	"\v<[0-9_]+(\.[0-9_]+)?([eE][+-]?[0-9_]+)?(\'(f|F)(32|64))?>"
endif

if nimrod_highlight_builtins == 1
  " builtin functions, types and objects, not really part of the syntax
  syn keyword nimrodBuiltin int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64 float float32 float64 bool
  syn keyword nimrodBuiltin char string cstring pointer range array openarray seq
  syn keyword nimrodBuiltin set Byte Natural Positive TObject PObject Conversion TResult TAddress
  syn keyword nimrodBuiltin BiggestInt BiggestFloat cchar cschar cshort cint csize cuchar cushort
  syn keyword nimrodBuiltin clong clonglong cfloat cdouble clongdouble cuint culong culonglong cchar
  syn keyword nimrodBuiltin cstringArray TEndian PFloat32 PFloat64 PInt64 PInt32
  syn keyword nimrodBuiltin TGC_Strategy TFile TFileMode TFileHandle isMainModule
  syn keyword nimrodBuiltin CompileDate CompileTime NimrodVersion NimrodMajor
  syn keyword nimrodBuiltin NimrodMinor NimrodPatch cpuEndian hostOS hostCPU inf
  syn keyword nimrodBuiltin neginf nan QuitSuccess QuitFailure dbgLineHook stdin
  syn keyword nimrodBuiltin stdout stderr defined new high low sizeof succ pred
  syn keyword nimrodBuiltin inc dec newSeq len incl excl card ord chr ze ze64
  syn keyword nimrodBuiltin toU8 toU16 toU32 abs min max add repr
  syn match   nimrodBuiltin "\<contains\>"
  syn keyword nimrodBuiltin toFloat toBiggestFloat toInt toBiggestInt addQuitProc
  syn keyword nimrodBuiltin copy setLen newString zeroMem copyMem moveMem
  syn keyword nimrodBuiltin equalMem alloc alloc0 realloc dealloc setLen assert
  syn keyword nimrodBuiltin swap getRefcount getCurrentException Msg
  syn keyword nimrodBuiltin getOccupiedMem getFreeMem getTotalMem isNil seqToPtr
  syn keyword nimrodBuiltin find pop GC_disable GC_enable GC_fullCollect
  syn keyword nimrodBuiltin GC_setStrategy GC_enableMarkAnd Sweep
  syn keyword nimrodBuiltin GC_disableMarkAnd Sweep GC_getStatistics GC_ref
  syn keyword nimrodBuiltin GC_ref GC_ref GC_unref GC_unref GC_unref quit
  syn keyword nimrodBuiltin OpenFile OpenFile CloseFile EndOfFile readChar
  syn keyword nimrodBuiltin FlushFile readFile write readLine writeln writeln
  syn keyword nimrodBuiltin getFileSize ReadBytes ReadChars readBuffer writeBytes
  syn keyword nimrodBuiltin writeChars writeBuffer setFilePos getFilePos
  syn keyword nimrodBuiltin fileHandle countdown countup items lines
endif

if nimrod_highlight_exceptions == 1
  " builtin exceptions and warnings
  syn keyword nimrodException E_Base EAsynch ESynch ESystem EIO EOS
  syn keyword nimrodException ERessourceExhausted EArithmetic EDivByZero
  syn keyword nimrodException EOverflow EAccessViolation EAssertionFailed
  syn keyword nimrodException EControlC EInvalidValue EOutOfMemory EInvalidIndex
  syn keyword nimrodException EInvalidField EOutOfRange EStackOverflow
  syn keyword nimrodException ENoExceptionToReraise EInvalidObjectAssignment
  syn keyword nimrodException EInvalidObject EInvalidLibrary EInvalidKey
  syn keyword nimrodException EInvalidObjectConversion EFloatingPoint
  syn keyword nimrodException EFloatInvalidOp EFloatDivByZero EFloatOverflow
  syn keyword nimrodException EFloatInexact EDeadThread
endif

if nimrod_highlight_space_errors == 1
  " trailing whitespace
  syn match   nimrodSpaceError   display excludenl "\S\s\+$"ms=s+1
  " any tabs are illegal in nimrod
  syn match   nimrodSpaceError   display "\t"
endif

syn sync match nimrodSync grouphere NONE "):$"
syn sync maxlines=200
syn sync minlines=2000

if version >= 508 || !exists("did_nimrod_syn_inits")
  if version <= 508
    let did_nimrod_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink nimrodBrackets       Operator
  HiLink nimrodKeyword	      Keyword
  HiLink nimrodFunction	    	Function
  HiLink nimrodConditional	  Conditional
  HiLink nimrodRepeat		      Repeat
  HiLink nimrodString		      String
  HiLink nimrodRawString	    String
  HiLink nimrodBoolean        Boolean
  HiLink nimrodEscape		      Special
  HiLink nimrodOperator		    Operator
  HiLink nimrodPreCondit	    PreCondit
  HiLink nimrodComment		    Comment
  HiLink nimrodTodo		        Todo
  HiLink nimrodDecorator	    Define
  
  if nimrod_highlight_numbers == 1
    HiLink nimrodNumber	Number
  endif
  
  if nimrod_highlight_builtins == 1
    HiLink nimrodBuiltin	Number
  endif
  
  if nimrod_highlight_exceptions == 1
    HiLink nimrodException	Exception
  endif
  
  if nimrod_highlight_space_errors == 1
    HiLink nimrodSpaceError	Error
  endif

  delcommand HiLink
endif

let b:current_syntax = "nimrod"

