# squeeze

run 'a\n\n\n\nb\n' squeeze
check 'collapses a run of empty lines' 0 'a\n\nb\n'

run 'a\n \n\t\n\nb\n' squeeze
check 'blank-only lines count as blank' 0 'a\n\nb\n'

run '\n\na\n\n' squeeze
check 'keeps one blank line at either end' 0 '\na\n\n'

run 'a\nb\n' squeeze
check 'leaves text without blank lines alone' 0 'a\nb\n'
