#!/bin/bash

setup() {
  source ./parkdown.sh
}

# Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse
# molestie consequat, vel illum dolore eu feugiat
# nulla facilisis at vero eros et accumsan et iusto odio
# dignissim qui blandit praesent luptatum zzril delenit augue
# duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit
# amet, consectetuer adipiscing elit, sed diam nonummy nibh
# euismod tincidunt ut laoreet dolore magna aliquam erat
# volutpat. 


test__shorter_strings_should_return_unchanged() {
  assertEquals "a line" "$(echo 'a line' | ./parkdown.sh)"
}

test__strings_shorter_than_max_line_should_return_unchanged() {
  input='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse m.'
  expected='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse m.'
  assertEquals "$expected" "$(echo "$input" | ./parkdown.sh)"
}

test__strings_longer_than_max_line_should_break() {
  input='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse magic.'
  expected='Duis autem vel eum iriure dolor in hendrerit in vulputate velit
esse magic.'
  assertEquals "$expected" "$(echo "$input" | ./parkdown.sh)"
}

test__should_support_multiple_linebreaks() {
  input='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio.'
  expected='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse
molestie consequat, vel illum dolore eu feugiat nulla facilisis at
vero eros et accumsan et iusto odio.'
  assertEquals "$expected" "$(echo "$input" | ./parkdown.sh)"
}

test__should_support_multiple_input_lines() {
  input='
Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie
consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan
et iusto odio.'
  expected='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse
molestie consequat, vel illum dolore eu feugiat nulla facilisis at
vero eros et accumsan et iusto odio.'
  assertEquals "$expected" "$(echo "$input" | ./parkdown.sh)"
}


test__should_support_checking_shorter_indent() {
  export MAX_LINE_LENGTH=78
  input='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie
consequat, vel illum dolore eu feugiat nulla facilisis at vero.'
  expected='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse
molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero.'
  assertEquals "$expected" "$(echo "$input" | main)"
}

test__should_support_checking_shorter_indent_with_second_line() {
  # export MAX_LINE_LENGTH=78
  input='
Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie
consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et.'
  expected='Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse
molestie consequat, vel illum dolore eu feugiat nulla facilisis at
vero eros et.'
  assertEquals "$expected" "$(echo "$input" | main)"
}

test__should_support_multiple_input_lines() {
  # export MAX_LINE_LENGTH=78
  input='"Do one thing and do it well" is the principle of the Unix toolkit.
Editing text is a broad domain, and there are many related tasks with
which it overlaps. Vim acknowledges this by enabling certain tasks to be
outsourced to external programs which do that one thing, and do it well.
This episode will demonstrate how the par program can be used for
formatting text.'
  expected='"Do one thing and do it well" is the principle of the Unix toolkit.
Editing text is a broad domain, and there are many related tasks with
which it overlaps. Vim acknowledges this by enabling certain tasks to
be outsourced to external programs which do that one thing, and do it
well. This episode will demonstrate how the par program can be used
for formatting text.'
  assertEquals "$expected" "$(echo "$input" | main)"
}

test__should_support_multiple_input_lines2() {
  export MAX_LINE_LENGTH=31
  input='We the people of the United
States, in order to form a more
perfect union, establish
justice, insure domestic
tranquility, provide for the
common defense, promote the
general welfare, and secure the
blessing of liberty to
ourselves and our posterity, do
ordain and establish the
Constitution of the United
States of America.'
  expected='We the people of the United
States, in order to form a
more perfect union, establish
justice, insure domestic
tranquility, provide for the
common defense, promote the
general welfare, and secure
the blessing of liberty to
ourselves and our posterity,
do ordain and establish
the Constitution of the
United States of America.'
  assertEquals "$expected" "$(echo "$input" | main)"
}


test__should_support_multiple_input_lines3() {
  input='Par began in July 1993 as a small program designed to do one narrow
task: reformat a single paragraph that might have a border on either
side. It was pretty clean back then. Over the next three months, it very
rapidly expanded to handle multiple paragraphs, offer more options, and
take better guesses, at the cost of becoming extremely complex, and
very unclean. It is nowhere near the optimal design for the larger task
it now tries to address. Its only redeeming features are that it is
extremely useful (I find it indispensable), extremely portable, and very
stable since version 1.41 released on 1993-Oct-31.'
  expected='Par began in July 1993 as a small program designed to do one narrow
task: reformat a single paragraph that might have a border on either
side. It was pretty clean back then. Over the next three months,
it very rapidly expanded to handle multiple paragraphs, offer more
options, and take better guesses, at the cost of becoming extremely
complex, and very unclean. It is nowhere near the optimal design for
the larger task it now tries to address. Its only redeeming features
are that it is extremely useful (I find it indispensable), extremely
portable, and very stable since version 1.41 released on 1993-Oct-31.'
  assertEquals "$expected" "$(echo "$input" | main)"
}


ttest__should_balance_basic_lines() {
  pushStack "Duis autem vel eum iriure"
  pushStack "consequat, vel"
  balanceLinesInStack

  assertEquals "Duis autem vel eum" "$STACK2"
  assertEquals "iriure consequat, vel" "$STACK1"
}

totest__push_in_stack() {
  soutput="$(
    pushStack "line1"
    pushStack "line2"
    pushStack "line3"
    pushStack "line4"
  )"
  assertEquals "line1" "$output"

  output="$(
    pushStack "line1"
    pushStack "line2"
    pushStack "line3"
    pushStack "line4"
    pushStack "line5"
  )"
  assertEquals $'line1\nline2' "$output"

  output="$(
    pushStack "line1"
    bufClear
  )"
  assertEquals $'line1' "$output"

  output="$(
    pushStack "line1"
    pushStack "line2"
    bufClear
  )"
  assertEquals $'line1\nline2' "$output"
}

# Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie
# consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et
# accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit
# augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet,
# consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut
# laoreet dolore magna aliquam erat volutpat. 
