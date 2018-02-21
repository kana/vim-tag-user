runtime! plugin/tag/user.vim

function! TagUserGuessSample()
  return 2
endfunction

describe ':Tag'
  before
    new
  end

  after
    close!
  end

  it 'behaves the same as :tag for not configured files'
    edit t/fixtures/doc.md
    call search('doSomething', 'cw')
    Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/doc.md', 2, 6]
    Expect exists('b:tag_user_guess') to_be_false

    " Jump to Aaa::doSomething even if the target code is Ccc::doSomething.
    Tag doSomething
    Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/aaa.php', 5, 1]
  end

  it 'jumps to more better place according to b:tag_user_guess'
    edit t/fixtures/doc.md
    call search('doSomething', 'cw')
    let b:tag_user_guess = 'TagUserGuessSample'
    Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/doc.md', 2, 6]
    Expect exists('b:tag_user_guess') to_be_true

    Tag doSomething
    Expect [expand('%'), line('.'), col('.')] ==# ['t/fixtures/bbb.php', 5, 1]
  end
end
