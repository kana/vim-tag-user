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

  context '<C-]>'
    it 'behaves the same as :tag for not configured files'
      call s:pattern("normal \<C-]>", ['t/fixtures/aaa.php', 5, 1], 0)
    end

    it 'jumps to more better place according to b:tag_user_guess'
      call s:pattern("normal \<C-]>", ['t/fixtures/bbb.php', 5, 1], 'Guess1')
    end
  end

  context '<Plug>(tag-user-<C-]>)'
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
end
