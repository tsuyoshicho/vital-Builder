let s:toml = expand('<sfile>:h') . '/Grep.toml'

function! s:_vital_loaded(V) abort
  let s:V = a:V
  let s:TOML = s:V.import('Text.TOML')
  let s:Type = s:V.import('Vim.Type')
  let s:List = s:V.import('Data.List')

  let s:config = s:TOML.parse_file(s:toml)
  let s:modules = {}

  if !has_key(s:config,'tool')
    call s:_throw('config file error: config.tool not found')
  else
    for item in s:config.tool
      if executable(item.command)
        let s:modules[item.name] = item
      endif
    endfor
  endif
endfunction

function! s:_vital_depends() abort
  return {
    \ 'modules': ['Text.TOML', 'Vim.Type', 'Data.List'],
    \ 'files':   ['Grep.toml'],
    \}
endfunction

function! s:_throw(msg) abort
  throw printf('vital: App.Grep: %s', a:msg)
endfunction

" Grep API
function! s:get(...) abort
  let keys = keys(s:modules)
  let priolist = []
  if a:0 > 0
    if type(a:1) == s:Type.types.list
      let priolist = a:1
    elseif type(a:1) == s:Type.types.string
      let priolist = [a:1]
    else
      call s:_throw('invalid argument')
    endif
  else
    " default prioriy list not now
    let priolist = copy(keys)
  endif
  " intersection key and request list
  let itemlist =  s:List.intersect(keys, priolist)
  if len(itemlist) > 0
    " curent direct return info
    " future: returen builder object
    return s:modules[itemlist[0]]
  else
    " not item
    return v:null
  endif
endfunction

" debug
function! s:dump() abort
  for [itemname, module] in items(s:modules)
    echomsg 'item:' itemname ' module:' module
  endfor
  echomsg s:config
endfunction
