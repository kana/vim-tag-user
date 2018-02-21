runtime! plugin/tag/user.vim

function! Guess()
  return 2
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

describe ':Tag'
  it 'behaves the same as :tag for not configured files'
    call s:pattern('Tag doSomething', ['t/fixtures/aaa.php', 5, 1], 0)
  end

  it 'jumps to more better place according to b:tag_user_guess'
    call s:pattern('Tag doSomething', ['t/fixtures/bbb.php', 5, 1], 'Guess')
  end
end
