use v6.c;

# Reference:
# https://machmotion.com/downloads/GCode/Mach4-G-and-M-Code-Reference-Manual.pdf

grammar GCodes {

  rule TOP {
    :i <commands>+
  }

  proto rule g-code { * }

  rule commands {
    :i <g-code>
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
  token p   { 'P' <num> }
  token q   { 'Q' <num> }
  token r   { 'R' <num> }
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

  # cw: May be another mode for g0, as I've seen it encompass multiple
  #     G-codes in the reference. Please investigate.
  rule g-code:sym<g00>   { 'G00' [ <x> <y> <z> | <g-code> ] }
  rule g-code:sym<g01>   { 'G01' <x> <y> <z>  }
  rule g-code:sym<g02>   { 'G02' <arcpos> <f> }
  rule g-code:sym<g03>   { 'G03' <xyz> ** 2 <r> <f> }
  rule g-code:sym<g04>   { 'G04' <p> }
  rule g-code:sym<g09>   { 'G09' <x> <y> <f> }

  rule g-code:sym<g10> {
    'G10' <l> [
       <x> <y> <z> <a> <b> <c> |
       <p> <z> <w> <d> <r> <x> <u> <y> <v> <q>
    ]
  }

  rule circle-params { <i> <j> [ <f> | <p> <q> ] }

  rule g-code:sym<g12>   { 'G12' <circle-params> } # Clockwise
  rule g-code:sym<g13>   { 'G13' <circle-params> } # Counter-Clockwise

  rule g-code:sym<g15>   { 'G15' }
  rule g-code:sym<g16>   { 'G16' [ <x> <y> <z> ]? }

  rule g-code:sym<g17>   { 'G17' <g-code>? }
  rule g-code:sym<g18>   { 'G18' <g-code>? }
  rule g-code:sym<g19>   { 'G19' <g-code>? }

  sub token-check ($_) {
    my $t = .keys.head;
    %*tokens{ $t } ?? False !! %*tokens{ $t } = 1
  }

  token axis3 { [ <x> | <y> | <z> ]                   <?{ token-check( $/ ) }> }
  token axis6 { [ <x> | <y> | <z> | <a> | <b> | <c> ] <?{ token-check( $/ ) }> }
  token abc   { [ <a> | <b> | <c> ]                   <?{ token-check( $/ ) }> }

  rule axes6 { :my %*tokens; <axis6> ** 1..6 }
  rule axes3 { :my %*tokens; <axis3> ** 1..3 }
  rule abc   { :my %*tokens; <abc>   ** 1..3 }

  rule g-code:sym<g28>   { 'G28'     <axes6>      }
  rule g-code:sym<g30>   { 'G30' <p> <axes6>      }
  rule g-code:sym<g31>   { 'G31' <x> <y> <z> <f>  }
  rule g-code:sym<g32>   { 'G32' <x> <y> <z> <f>  }
  rule g-code:sym<g40>   { 'G40' <g-code>?        }

  rule comp-args { <d> <axes3> <f> }

  rule g-code:sym<g41>   { 'G41' <comp-args> }
  rule g-code:sym<g42>   { 'G42' <comp-args> }

  rule tooloff-args      { <h> <axes3> }
  rule g-code:sym<g43>   { 'G43' <tooloff-args> }
  rule g-code:sym<g44>   { 'G44' <tooloff-args> }

  rule g-code:sym<g49>   { 'G49' <g-code>? }
  rule g-code:sym<g50>   { 'G50' <g-code>? }

  rule g-code:sym<g51>   { 'G51' <axes6> }
  rule g-code:sym<g52>   { 'G52' <axes6> }

  # cw: Missing G54-G59
  rule g-code:sym<g54-1> { 'G54.1' <p> }

  rule g-code:sym<g60>   { 'G60' <axes3> }

  rule g-code:sym<g61>   { 'G61' <g-code>?   }
  rule g-code:sym<g64>   { 'G64' <g-code>?   }
  rule g-code:sym<g65>   { 'G65' <p> <abc>   }
  rule g-code:sym<g66>   { 'G66' <p> <abc>   }
  rule g-code:sym<g67>   { 'G67' <g-code>?   }
  rule g-code:sym<g68>   { 'G68' <x> <y> <r> }
  rule g-code:sym<g69>   { 'G69' <g-code>?   }

  rule g-code:sym<g73>   { 'G73' <axes3> <r> <q> <f> }
  rule g-code:sym<g74>   { 'G74' <axes3> <r> <f>     }
  rule g-cpde:sym<g76>   { 'G76' <axes3> <r> <i> <j> <p> <f> }

  rule g-code:sym<g80>   { 'G80' }
  rule g-code:sym<g81>   { 'G81' <axes3> <r> <f> }

  rule g-code:sym<g82>   { 'G82' <axes3> <r> <p> <f> }
  rule g-code:sym<g83>   { 'G83' <axes3> <r> <q> <f> }

  rule boring-args       { <axes3> <r> <f> }
  rule boring-args2      { <axes3> <r> <p> <f> }

  rule g-code:sym<g84>   { 'G84' <boring-args> }
  rule g-code:sym<g85>   { 'G85' <boring-args> }
  rule g-code:sym<g86>   { 'G86' <boring-args> }

  rule g-code:sym<g87>   { 'G87' <axes3> <r> <i> <j> <f> }

  rule g-code:sym<g88>   { 'G88' <boring-args2> }
  rule g-code:sym<g89>   { 'G89' <boring-args2> }

  rule g-code:sym<g90>   { 'G90'   <g-code>? }
  rule g-code:syM<g90-1> { 'G90.1' <g-code>? }
  rule g-code:sym<g91>   { 'G91'   <g-code>? }
  rule g-code:sym<g91-1> { 'G91.1' <g-code>? }

  rule g-code:sym<g92>   { 'G92' <axes3> <abc> }
  rule g-code:sym<g92-1> { 'G92.1' <g-code>? }

}
