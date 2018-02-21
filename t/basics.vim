runtime! plugin/tag/user.vim

function! Guess1()
  return [2, 0]
endfunction

function! Guess2()
  return [0, 'Ccc']
endfunction

function! s:pattern(jump_command, expected_file_line_col, hook)
  edit t/fixtures/doc.md
  call search('doSomething', 'cw')
  Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/doc.md', 2, 6]
  Expect exists('b:tag_user_guess') to_be_false
  if a:hook isnot 0
    let b:tag_user_guess = a:hook
  endif

  execute a:jump_command
  Expect [expand('%'), line('.'), col('.')] ==# a:expected_file_line_col
endfunction

describe 'tag-user'
  after
    % bdelete
  end

  it 'behaves the same as :tag for not configured files with :Tag'
    call s:pattern('Tag doSomething', ['t/fixtures/aaa.php', 5, 1], 0)
  end

  it 'behaves the same as :tag for not configured files with <C-]>'
    call s:pattern("normal \<C-]>", ['t/fixtures/aaa.php', 5, 1], 0)
  end

  it 'behaves the same as :tag for not configured files with <Plug>(tag-user-<C-]>)'
    call s:pattern("normal \<Plug>(tag-user-\<C-]>)", ['t/fixtures/aaa.php', 5, 1], 0)
  end

  it 'jumps to more better place according to b:tag_user_guess with :Tag'
    call s:pattern('Tag doSomething', ['t/fixtures/bbb.php', 5, 1], 'Guess1')
  end

  it 'jumps to more better place according to b:tag_user_guess with <C-]>'
    call s:pattern("normal \<C-]>", ['t/fixtures/bbb.php', 5, 1], 'Guess1')
  end

  it 'jumps to more better place according to b:tag_user_guess with <Plug>(tag-user-<C-]>)'
    call s:pattern("normal \<Plug>(tag-user-\<C-]>)", ['t/fixtures/bbb.php', 5, 1], 'Guess1')
  end

  it 'uses another identifier if b:tag_user_guess returns so'
    call s:pattern('Tag doSomething', ['t/fixtures/ccc.php', 3, 1], 'Guess2')
  end
end
