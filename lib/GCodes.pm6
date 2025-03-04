use v6.c;

# Reference:
# https://machmotion.com/downloads/GCode/Mach4-G-and-M-Code-Reference-Manual.pdf

grammar GCodes {

  rule TOP {
    :i <commands>+
  }

  proto rule  g-code    { * }
  proto rule  m-code    { * }
  proto token misc-code { * }

  rule commands {
    :i $<i>=[
      <g-code>    |
      <m-code>    |
      <misc-code>
    ]
  }

  token num { '-'? $<r>=\d+ $<f>=[ '.' \d+ ]? }
  token a   { 'A' <num> }
  token b   { 'B' <num> }
  token c   { 'C' <num> }
  token d   { 'D' <num> }
  token f   { 'F' <num> }
  token h   { 'H' <num> }
  token i   { 'I' <num> }
  token j   { 'J' <num> }
  token k   { 'K' <num> }
  token l   { 'L' <num> }
  token n   { 'N' <num> }
  token p   { 'P' <num> }
  token q   { 'Q' <num> }
  token r   { 'R' <num> }
  token s   { 'S' <num> }
  token t   { 'T' <num> }
  token u   { 'U' <num> }
  token v   { 'V' <num> }
  token w   { 'W' <num> }
  token x   { 'X' <num> }
  token y   { 'Y' <num> }
  token z   { 'Z' <num> }

  rule xyz { <x> | <y> | <z> }

  rule ijk { <i> | <j> | <k> }

  rule arcpos {
    <xyz> ** 2
    <ijk> ** 2
  }

  sub token-check ($_) {
    my $t = .keys.head;
    %*tokens{ $t } ?? False !! %*tokens{ $t } = 1
  }

  token axis3 { [ <x> | <y> | <z> ]                   <?{ token-check( $/ ) }> }
  token axis6 { [ <x> | <y> | <z> | <a> | <b> | <c> ] <?{ token-check( $/ ) }> }
  token abc   { [ <a> | <b> | <c> ]                   <?{ token-check( $/ ) }> }

  rule axes2 { :my %*tokens; <axes3> ** 1..2 }
  rule axes3 { :my %*tokens; <axis3> ** 1..3 }
  rule axes6 { :my %*tokens; <axis6> ** 1..6 }

  # cw: May be another mode for g0, as I've seen it encompass multiple
  #     G-codes in the reference. Please investigate.
  rule g-code:sym<g00>   { $<code>='G00' [ <axes3> | <g-code> ] }
  rule g-code:sym<g01>   { $<code>='G01' <axes3>  }
  rule g-code:sym<g02>   { $<code>='G02' <arcpos> <f> }
  rule g-code:sym<g03>   { $<code>='G03' <axes2> <r> <f> }
  rule g-code:sym<g04>   { $<code>='G04' <p> }
  rule g-code:sym<g09>   { $<code>='G09' <x> <y> <f> }

  rule g-code:sym<g10> {
    'G10' <l> [
       <axes6> |
       <p> <z> <w> <d> <r> <x> <u> <y> <v> <q>
    ]
  }

  rule circle-params { <i> <j> [ <f> | <p> <q> ] }

  rule g-code:sym<g12>   { $<code>='G12' <circle-params> } # Clockwise
  rule g-code:sym<g13>   { $<code>='G13' <circle-params> } # Counter-Clockwise

  rule g-code:sym<g15>   { $<code>='G15' }
  rule g-code:sym<g16>   { $<code>='G16' <axes3>? }

  rule g-code:sym<g17>   { $<code>='G17' <g-code>? }
  rule g-code:sym<g18>   { $<code>='G18' <g-code>? }
  rule g-code:sym<g19>   { $<code>='G19' <g-code>? }

  rule g-code:sym<g28>   { $<code>='G28'     <axes6>  }
  rule g-code:sym<g30>   { $<code>='G30' <p> <axes6>  }
  rule g-code:sym<g31>   { $<code>='G31' <axes3> <f>  }
  rule g-code:sym<g32>   { $<code>='G32' <axes3> <f>  }
  rule g-code:sym<g40>   { $<code>='G40' <g-code>?    }

  rule comp-args { <d> <axes3> <f> }

  rule g-code:sym<g41>   { $<code>='G41' <comp-args> }
  rule g-code:sym<g42>   { $<code>='G42' <comp-args> }

  rule tooloff-args      { <h> <axes3> }
  rule g-code:sym<g43>   { $<code>='G43' <tooloff-args> }
  rule g-code:sym<g44>   { $<code>='G44' <tooloff-args> }

  rule g-code:sym<g49>   { $<code>='G49' <g-code>? }
  rule g-code:sym<g50>   { $<code>='G50' <g-code>? }

  rule g-code:sym<g51>   { $<code>='G51' <axes6> }
  rule g-code:sym<g52>   { $<code>='G52' <axes6> }

  # cw: Missing G54-G59
  rule g-code:sym<g54-1> { $<code>='G54.1' <p> }

  rule g-code:sym<g60>   { $<code>='G60' <axes3> }

  rule g-code:sym<g61>   { $<code>='G61' <g-code>?   }
  rule g-code:sym<g64>   { $<code>='G64' <g-code>?   }
  rule g-code:sym<g65>   { $<code>='G65' <p> <abc>   }
  rule g-code:sym<g66>   { $<code>='G66' <p> <abc>   }
  rule g-code:sym<g67>   { $<code>='G67' <g-code>?   }
  rule g-code:sym<g68>   { $<code>='G68' <x> <y> <r> }
  rule g-code:sym<g69>   { $<code>='G69' <g-code>?   }

  rule g-code:sym<g73>   { $<code>='G73' <axes3> <r> <q> <f> }
  rule g-code:sym<g74>   { $<code>='G74' <axes3> <r> <f>     }
  rule g-cpde:sym<g76>   { $<code>='G76' <axes3> <r>? <i>? <j>? <p>? <l>? <f>? }

  rule boring-args       { <axes3> <r>? <p>? <l>? <f>? }
  rule boring-args2      { <axes3> <r>? <p>? <f>? }

  rule tapping-args      { <axes3> <r>? <p>? <l>? <f>? <j>? }

  rule g-code:sym<g80>   { $<code>='G80' }
  rule g-code:sym<g81>   { $<code>='G81'   <axes3> <r> <f> }
  rule g-code:sym<g82>   { $<code>='G82'   <axes3> <r> <p> <f> }
  rule g-code:sym<g83>   { $<code>='G83'   <axes3> <r> <q> <f> }
  rule g-code:sym<g84>   { $<code>='G84'   <boring-args>  }
  rule g-code:sym<g84-2> { $<code>='G84.2' <tapping-args> }
  rule g-code:sym<g84-3> { $<code>='G84.3' <tapping-args> }
  rule g-code:sym<g85>   { $<code>='G85'   <boring-args>  }
  rule g-code:sym<g86>   { $<code>='G86'   <boring-args>  }
  rule g-code:sym<g87>   { $<code>='G87'   <axes3> <r>? <i>? <j>? <p>? <l>? <f>? }
  rule g-code:sym<g88>   { $<code>='G88'   <boring-args2> }
  rule g-code:sym<g89>   { $<code>='G89'   <boring-args2> }

  rule g-code:sym<g90>   { $<code>='G90'   <g-code>? }
  rule g-code:syM<g90-1> { $<code>='G90.1' <g-code>? }
  rule g-code:sym<g91>   { $<code>='G91'   <g-code>? }
  rule g-code:sym<g91-1> { $<code>='G91.1' <g-code>? }
  rule g-code:sym<g92>   { $<code>='G92'   <axes6>   }
  rule g-code:sym<g92-1> { $<code>='G92.1' <g-code>? }
  rule g-code:sym<g93>   { $<code>='G93'   <f>?      }
  rule g-code:sym<g94>   { $<code>='G94'   <g-code>? }
  rule g-code:sym<g95>   { $<code>='G95'   <g-code>? }
  rule g-code:sym<g96>   { $<code>='G96'   <g-code>? }
  rule g-code:sym<g97>   { $<code>='G97'   <g-code>? }
  rule g-code:sym<g98>   { $<code>='G98'   <g-code>? }
  rule g-code:sym<g99>   { $<code>='G99'   <g-code>? }

  rule m-code:sym<m00>   { $<code>='M00' }
  rule m-code:sym<m01>   { $<code>='M01' }
  rule m-code:sym<m02>   { $<code>='M02' }
  rule m-code:sym<m03>   { $<code>='M03' <s>? }
  rule m-code:sym<m04>   { $<code>='M04' <s>? }
  rule m-code:sym<m05>   { $<code>='M05' }
  rule m-code:sym<m06>   { <t>? $<code>='M06' }
  rule m-code:sym<m07>   { $<code>='M07' }
  rule m-code:sym<m08>   { $<code>='M08' }
  rule m-code:sum<m09>   { $<code>='M09' }

  rule m-code:sum<m19>   { $<code>='M19' }

  rule m-code:sum<m30>   { $<code>='M30' }

  rule m-code:sum<m40>   { $<code>='M40' }
  rule m-code:sum<m41>   { $<code>='M41' }
  rule m-code:sum<m42>   { $<code>='M42' }
  rule m-code:sum<m43>   { $<code>='M43' }
  rule m-code:sum<m44>   { $<code>='M44' }
  rule m-code:sum<m45>   { $<code>='M45' }
  rule m-code:sum<m47>   { $<code>='M47' }
  rule m-code:sum<m48>   { $<code>='M48' }
  rule m-code:sum<m49>   { $<code>='M49' }

  rule m-code:sum<m98>   { $<code>='M98' <p> <q>? <l>? }
  rule m-code:sum<m99>   { $<code>='M99' <p>? }

  token misc-code:<s>    { $<code>=<s> }
  token misc-code:<t>    { $<code>=<t> }
  token misc-code:<f>    { $<code>=<f> }
  token misc-code:<p>    { $<code>=<p> }
  token misc-code:<n>    { $<code>=<n> }
}
