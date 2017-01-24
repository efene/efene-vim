" indent/swift.vim
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

setlocal indentexpr=EfeneIndent()

if exists("*EfeneIndent")
   finish
endif

function! FnNextNonBlankLine(lnum)
    let numlines = line('$')
    let current = a:lnum + 1

    while current <= numlines
        if getline(current) =~? '\v\S'
            return current
        endif

        let current += 1
    endwhile

    return -2
endfunction


function! EfeneIndent()
  let this_line = getline(v:lnum)
  let previousNum = prevnonblank(v:lnum - 1)
  let previous = getline(previousNum)
  let nextLineNum = FnNextNonBlankLine(v:lnum)
  let nextLine = getline(nextLineNum)
  let indnt = indent(previousNum)

  if a:line_num == 0
      return 0
  endif

  if this_line =~ '^\s\+fn\s\+'
    return indnt
  endif

  if this_line =~ '^\s*end\s*$'
      if nextLine =~ '^\s*fn\s\+' || nextLineNum == ''
          return 0
      endif

      return indnt - &shiftwidth
  endif

  if this_line =~ '^\s*->'
      if previous =~ '^\s*->'
          return indnt
      endif

      return indnt + &shiftwidth
  endif

  if previous =~ ':\s*$'
    return indnt + &shiftwidth
  endif

  if this_line =~ '\s\+catch\s*' || this_line =~ '\s\+after\s*'
    return indnt - &shiftwidth
  endif

  if previous =~ 'begin\s*$' || previous =~ '\s\+try\s*$' || previous =~ '\s\+catch\s*' || previous =~ '\s\+after\s*' || previous =~ '\s\+receive\s*'
    return indnt + &shiftwidth
  endif

  if this_line =~ '^\s*case\s\+' && (previous =~ '\s+fn\s*$' || previous =~ '\s\+fn\s\+[A-Z][A-Za-z]*\s*$')
      return indnt + &shiftwidth
  endif

  if this_line =~ '^\s\+case\s\+' && previous =~ '^\s\+match\s\+'
    return indnt + &shiftwidth
  endif

  if this_line =~ '^\s*case\(\s\+\|:\)'
      if previous =~ '^\s*case\s\+'
          return indnt
      endif

      if previous =~ '^\s*fn\s\+'
          return indnt + &shiftwidth
      endif

      return indnt - &shiftwidth
  endif

  if this_line =~ '^\s*else\(\s\+\|:\)'
      if previous =~ '^\s*else\(\s\+\|:\)' || previous =~ '\s\+when\s*'
          return indnt
      endif

      return indnt - &shiftwidth
  endif

  return indnt

endfunction
