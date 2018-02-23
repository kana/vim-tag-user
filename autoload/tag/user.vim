" tag-user - Extensible :tag wrapper
" Version: 0.1.0
" Copyright (C) 2018 Kana Natsuno <https://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

function! tag#user#jump(count, precommand)
  let s_ident = expand('<cword>')
  let s_count = a:count == 0 ? '' : a:count
  if s_ident == ''
    execute s_count 'tag'
    return
  endif

  if exists('b:tag_user_guess')
    let [c, ident] = {b:tag_user_guess}()
    if c != 0
      let s_count = c
    endif
    if ident isnot 0
      let s_ident = ident
    endif
  endif

  if a:precommand != '' && s:exists_definition(s_ident)
    execute a:precommand
  endif
  execute s_count 'tag' s_ident
endfunction

function! s:exists_definition(ident)
  return len(taglist(s:full_match_regexp_from(a:ident), expand('%'))) > 0
endfunction

function! s:full_match_regexp_from(string)
  return '\V\^' . escape(a:string, '\') . '\$'
endfunction

" __END__  "{{{1
" vim: foldmethod=marker
