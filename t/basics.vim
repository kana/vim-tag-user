runtime! plugin/tag/user.vim

function! Guess1()
  return [2, 0]
endfunction

function! Guess2()
  return [0, 'Ccc']
endfunction

function! Guess3()
  let pos = getpos('.')
  let cword = expand('<cword>')
  normal! ^
  let prefix = expand('<cword>')
  call setpos('.', pos)

  let tags = taglist(cword, expand('%'))
  for tag in tags
    if has_key(tag, 'class') && tag.class ==# prefix
      return [index(tags, tag) + 1, 0]
    endif
  endfor

  return [0, 0]
endfunction

function! s:pattern(jump_command, to, hook)
  edit t/fixtures/doc.md
  call search('doSomething', 'cw')
  Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/doc.md', 2, 6]
  Expect exists('b:tag_user_guess') to_be_false
  if a:hook isnot 0
    let b:tag_user_guess = a:hook
  endif

  execute a:jump_command
  Expect [expand('%'), line('.'), col('.')] ==# a:to
endfunction

describe '<C-]>'
  it 'is bound to <Plug>(tag-user-<C-]>)'
    let maparg = maparg('<C-]>', 'n', 0, 1)
    Expect maparg.lhs ==# '<C-]>'
    Expect maparg.rhs ==# '<Plug>(tag-user-<C-]>)'
    Expect maparg.silent to_be_false
    Expect maparg.noremap to_be_false
    Expect maparg.expr to_be_false
    Expect maparg.buffer to_be_false
    Expect maparg.mode ==# 'n'
  end
end

describe '<Plug>(tag-user-<C-]>)'
  after
    % bdelete
  end

  it 'is bound to a magic stuff'
    let maparg = maparg('<Plug>(tag-user-<C-]>)', 'n', 0, 1)
    Expect maparg.lhs ==# '<Plug>(tag-user-<C-]>)'
    Expect stridx(maparg.rhs, 'tag#user#') != -1
    Expect maparg.silent to_be_true
    Expect maparg.noremap to_be_true
    Expect maparg.expr to_be_false
    Expect maparg.buffer to_be_false
    Expect maparg.mode ==# 'n'
  end

  it 'behaves the same as :tag for not configured files'
    call s:pattern("normal \<Plug>(tag-user-\<C-]>)", ['t/fixtures/aaa.php', 5, 1], 0)
  end

  it 'jumps to more better place according to b:tag_user_guess'
    call s:pattern("normal \<Plug>(tag-user-\<C-]>)", ['t/fixtures/bbb.php', 5, 1], 'Guess1')
  end

  it 'uses another identifier if b:tag_user_guess returns so'
    call s:pattern("normal \<Plug>(tag-user-\<C-]>)", ['t/fixtures/ccc.php', 3, 1], 'Guess2')
  end

  it 'uses the context if b:tag_user_guess is defined so'
    call s:pattern("normal \<Plug>(tag-user-\<C-]>)", ['t/fixtures/ccc.php', 5, 1], 'Guess3')
  end
end

describe 'tag#user#jump()'
  after
    % bdelete
  end

  it 'behaves the same as <Plug>(tag-user-<C-]>)'
    call s:pattern('call tag#user#jump(0, "")', ['t/fixtures/ccc.php', 3, 1], 'Guess2')
  end

  it 'runs {precommand} before jumping'
    Expect winnr('$') == 1
    call s:pattern('call tag#user#jump(0, "split")', ['t/fixtures/ccc.php', 3, 1], 'Guess2')
    Expect winnr('$') == 2
    wincmd w
    Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/doc.md', 2, 6]
  end
end
