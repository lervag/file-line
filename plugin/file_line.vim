if exists('g:loaded_file_line') || (v:version < 701)
  finish
endif
let g:loaded_file_line = 1


augroup file_line
  autocmd!
  autocmd VimEnter * call s:startup()
augroup END


function! s:startup()
  augroup file_line
    autocmd! BufNewFile * nested call s:goto_file_line()
    autocmd! BufRead    * nested call s:goto_file_line()
  augroup END

  let curidx = argidx()+1
  for argidx in range(0, argc()-1)
    noautocmd execute argidx+1 'argument'
    let argname = argv(argidx)
    let fname   = s:goto_file_line(argname)
    if fname != argname
      execute argidx+1 'argdelete'
      execute argidx   'argadd' fnameescape(fname)
    endif
    filetype detect
  endfor

  if argc() > 1
    noautocmd execute curidx . 'argument'
  endif
endfunction

function! s:goto_file_line(...)
  let file_line_col = a:0 > 0 ? a:1 : bufname('%')
  if filereadable(file_line_col) || file_line_col ==# ''
    return file_line_col
  endif

  " Regex to match variants like these
  "   file(10)
  "   file(line:col)
  "   file:line:column:
  "   file:line:column
  "   file:line
  let matches =  matchlist(file_line_col,
        \ '\(.\{-1,}\)[(:]\(\d\+\)\%(:\(\d\+\):\?\)\?')
  if empty(matches) | return file_line_col | endif

  let fname = matches[1]
  let line  = matches[2] ==# '' ? '0' : matches[2]
  let col   = matches[3] ==# '' ? '0' : matches[3]

  if filereadable(fname)
    let bufnr = bufnr('%')
    exec 'keepalt edit ' . fnameescape(fname)
    exec 'bwipeout ' bufnr

    exec line
    exec 'normal! ' . col . '|'
    normal! zv
    normal! zz
    filetype detect
  endif

  return fname
endfunction
