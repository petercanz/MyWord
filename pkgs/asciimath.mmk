
math:	= asciimath <math display=block>

:math	= asciimath <math display=inline>

asciimath	    := E*							:: (Es) => this.flatten(Es).join('')

    E 			:= ws (fraction / Sexp) ws		:: (ws1,exp,ws2) => [ws1,exp[0],ws2]

    Enoright 	:= !r E 						:: (_,exp) => exp

    fraction 	:= Sbr slash 					:: (s,slashOp) => ["<",slashOp[0],">",s,slashOp[1],"</",slashOp[0],">"]

    Sexp		:= S (slash / subsuper)			:: (s,ops) =>
                                                    (ops[0].length==0) ? s :
                                                    ["<",ops[0][0],">",s,ops[0].slice(1),"</",ops[0][0],">"]

    subsuper	:= subscript? superscript?		:: (sb,sp) =>
                                                    ((sb.length>0) && (sp.length>0)) ? ["msubsup",sb[0][1],sp[0][1]] :
                                                    ((sb.length>0) ? sb[0] :
                                                    ((sp.length>0) ? sp[0] :
                                                    []))

    slash 		:= slashOp Spr					:: (op,s) => ["mfrac",s]
    slashOp		:~ / (?! [/_])

    subscript	:= subOp Spr					:: (_,s) => ["msub",s]
    subOp		:~ _ (?! _[|] | [|]_)

    superscript	:= superOp Spr					:: (_,s) => ["msup",s]
    superOp 	:~ \^ (?! \^)

    Spr 		:= ws (Sbr / S)?				:: (_,s) => s

    Sbr 		:= l Enoright* r				:: (_l,exp,_r) => ["<mrow>",exp,"</mrow>"]

    l			:= l_ang / l_hidd / l_other
    l_ang		:~ [(]: | <<					:: () => "<mo>&#x2329;</mo>"
    l_hidd		:~ {:							:: () => []
    l_other		:~ [([{] | [|] (?! -- | == | __ | ~)
                                                :: (l) => ["<mo>",l,"</mo>"]

    r			:= r_ang / r_hidd / r_other
    r_ang		:~ :[)] | >>					:: (_) => "<mo>&#x232A;</mo>"
    r_hidd		:~ :}							:: (_) => []
    r_other		:~ [)\]}] | [|] (?! -- | == | __ | ~)
                                                :: (r) => ["<mo>",r,"</mo>"]


    ws 			:= (spaces / linebreak)*
    spaces		:~ [ \t]+						:: () => []
    linebreak	:~ [\r]? [\n]					:: () => "<mspace linebreak='newline'/>"


    S 			:=	S_bracketed /
                    S_quoted /
                    S_special /
                    S_constant


    S_bracketed	:= l (matrix / Enoright*) r		:: (left,content,right) => ["<mrow>",left,content[0],right,"</mrow>"]

    matrix		:= ws mxcontent ws				:: (_,content) => ["<mtable>",content,"</mtable>"]

    mxcontent 	:= (&'(' mxrowrnd (ws ',' mxrowrnd)+) /
                   (&'[' mxrowsqr (ws ',' mxrowsqr)+)
                                                :: (rowitems) => {				// ([_,row,rows]) => {
                                                    var result=[rowitems[1]]	// [row]
                                                    //rows.forEach(([_ws,_sep,row]) => result.push(row))
                                                    rowitems[2].forEach(function(rowitem){return result.push(rowitem[2])})
                                                    return result
                                                }

    mxrowrnd	:= !r ws '(' mxitems? ws ')'	:: (_,_ws,_r,items) => ["<mtr>",items,"</mtr>"]

    mxrowsqr	:= !r ws '[' mxitems? ws ']'	:: (_,_ws,_r,items) => ["<mtr>",items,"</mtr>"]

    mxitems		:= ws mxitem (ws ',' mxitem)*	:: (_,item,items) => {
                                                    var result=[item]
                                                    items.forEach(function(item){return result.push(item[2])})
                                                    return result
                                                }

    mxitem		:= (!',' Enoright)*				:: (items) => {
                                                    var result=["<mtd>"]
                                                    items.forEach(function(exp){return result.push(exp[1])})
                                                    result.push("</mtd>")
                                                    return result
                                                }


    S_quoted	:~ " ([^"]*) " 					:: (_,quoted) => ["<mtext>",quoted,"</mtext>"]


    S_special	:= grdspecial (
                    S_fenced /
                    S_frac /
                    S_root /
                    S_stackrel /
                    S_underset /
                    S_sqrt /
                    S_text /
                    S_font /
                    S_accover /
                    S_accunder /
                    S_underover)				:: (_,sp) => sp
    grdspecial	:~ (?= [a-zL^])


    S_fenced	:= abs / norm / floor / ceil
                                                :: (fenced) => ["<mrow>",fenced,"</mrow>"]
    abs			:= 'abs' Spr					:: (_,s) => ["<mo>|</mo>",s,"<mo>|</mo>"]
    norm		:= 'norm' Spr					:: (_,s) => ["<mo>&#x2225;</mo>",s,"<mo>&#x2225;</mo>"]
    floor		:= 'floor' Spr					:: (_,s) => ["<mo>&#x230A;</mo>",s,"<mo>&#x230B;</mo>"]
    ceil		:= 'ceil' Spr					:: (_,s) => ["<mo>&#x2308;</mo>",s,"<mo>&#x2309;</mo>"]


    S_frac		:= 'frac' Spr Spr				:: (_,s1,s2) => ["<mfrac>",s1,s2,"</mfrac>"]


    S_root		:= 'root' Spr Spr				:: (_,s1,s2) => ["<mroot>",s2,s1,"</mroot>"]


    S_stackrel	:= ('stackrel' / 'overset') Spr Spr
                                                :: (_,s1,s2) => ["<mover>",s2,s1,"</mover>"]


    S_underset	:= 'underset' Spr Spr			:: (_,s1,s2) => ["<munder>",s2,s1,"</munder>"]


    S_sqrt		:= 'sqrt' Spr 					:: (_,s) => ["<msqrt>",s,"</msqrt>"]


    S_text		:= 'text' (txtrnd / txtsq / txtcrly)
                                                :: (_,text) => ["<mtext>",text[0],"</mtext>"]
    txtrnd		:~ [(] ([^)]*) [)]				:: (_,text) => text
    txtsq		:~ [[] ([^\]]*) ]				:: (_,text) => text
    txtcrly		:~ { ([^}]*) }					:: (_,text) => text


    S_font		:= font Spr						:: (font,s) => ["<mstyle mathvariant='",font,"'>",s,"</mstyle>"]
    font		:~ b{2,3} | sf | cc | tt | fr	:: (style) =>
                                                    {return {"bbb":"double-struck",
                                                             "bb":"bold",
                                                             "sf":"sans-serif",
                                                             "cc":"script",
                                                             "tt":"monospace",
                                                             "fr":"fraktur"}[style]
                                                    }


    S_accover	:= accover Spr					:: (acc,s) => ["<mover accent=true>",s,acc,"</mover>"]
    accover		:~ tilde | hat | bar | vec | ddot(?!s) | dot | obrace
                                                :: (acc) => ["<mo>",
                                                             {"tilde"	:"~",
                                                              "hat"		:"^",
                                                              "bar"		:"&#xaf;",
                                                              "vec"		:"&#x2192;",
                                                              "dot"		:".",
                                                              "ddot"	:"..",
                                                              "obrace"	:"&#x23de;"}[acc],
                                                             "</mo>"]


    S_accunder	:= accunder Spr					:: (acc,s) => ["<munder accent=true>",s,acc,"</munder>"]
    accunder	:~ ul | ubrace					:: (acc) => ["<mo>",
                                                             {"ul"		:"&#x332;",
                                                              "ubrace"	:"&#x23df;"}[acc],
                                                             "</mo>"]


    S_underover := underover subscript? superscript?
                                                :: (op,sb,sp) =>
                                                    ((sb.length>0) && (sp.length>0)) ?
                                                            ["<munderover>",op,sb[0][1],sp[0][1],"</munderover>"] :
                                                    ((sb.length>0) ? ["<munder>",op,sb[0][1],"</munder>"] :
                                                    ((sp.length>0) ? ["<mover>",op,sp[0][1],"</mover>"] :
                                                    op))
    underover	:~ sum | prod | \^\^\^ | vvv | nnn | uuu | lim | Lim | min | max
                                                :: (op) => ["<mo>",
                                                            {"sum"		:"&#x2211;",
                                                             "prod"		:"&#x220f;",
                                                             "^^^"		:"&#x22c0;",
                                                             "vvv"		:"&#x22c1;",
                                                             "nnn"		:"&#x22c2;",
                                                             "uuu"		:"&#x22c3;",
                                                             "lim"		:"lim",
                                                             "Lim"		:"Lim",
                                                             "min"		:"min",
                                                             "max"		:"max"}[op],
                                                            "</mo>"]


    S_constant	:= number / idsymbol / opsymbol / derivative / letter / escape / other

    number		:~ [-]? \d+ (?: [.]\d*)?		:: (num) => ["<mn>",num,"</mn>"]

    idsymbol	:~ alpha | beta | chi | delta | epsi | varepsilon | eta | gamma | iota | kappa | lambda | lamda | mu |
                    nu | omega | phi | varphi | pi | psi | Psi | rho | sigma | tau | theta | vartheta | upsilon | xi | zeta
                                                :: (id) => ["<mi>",
                                                             {"alpha"		:"&#x3b1;",
                                                              "beta"		:"&#x3b2;",
                                                              "chi"			:"&#x3c7;",
                                                              "delta"		:"&#x3b4;",
                                                              "epsi"		:"&#x3b5;",
                                                              "varepsilon"	:"&#x25b;",
                                                              "eta"			:"&#x3b7;",
                                                              "gamma"		:"&#x3b3;",
                                                              "iota"		:"&#x3b9;",
                                                              "kappa"		:"&#x3ba;",
                                                              "lambda"		:"&#x3bb;",
                                                              "lamda"		:"&#x3bb;",
                                                              "mu"			:"&#x3bc;",
                                                              "nu"			:"&#x3bd;",
                                                              "omega"		:"&#x3c9;",
                                                              "phi"			:"&#x3d5;",
                                                              "varphi"		:"&#x3c6;",
                                                              "pi"			:"&#x3c0;",
                                                              "psi"			:"&#x3c8;",
                                                              "Psi"			:"&#x3a8;",
                                                              "rho"			:"&#x3c1;",
                                                              "sigma"		:"&#x3c3;",
                                                              "tau"			:"&#x3c4;",
                                                              "theta"		:"&#x3b8;",
                                                              "vartheta"	:"&#x3d1;",
                                                              "upsilon"		:"&#x3c5;",
                                                              "xi"			:"&#x3be;",
                                                              "zeta"		:"&#x3b6;"}[id],
                                                            "</mi>"]

    opsymbol 	:~ %greekSyms | %binarySyms | %miscSyms | %funcSyms | %arrowSyms
                                                :: (sym) => {
                                                        var output = {
                                                            "Delta"		:"&#x394;",
                                                            "Gamma"		:"&#x393;",
                                                            "Lambda"	:"&#x39b;",
                                                            "Lamda"		:"&#x39b;",
                                                            "Omega"		:"&#x3a9;",
                                                            "Phi"		:"&#x3a6;",
                                                            "Pi"		:"&#x3a0;",
                                                            "Sigma"		:"&#x3a3;",
                                                            "Theta"		:"&#x398;",
                                                            "Xi"		:"&#x39e;",
                                                            "*"			:"&#x22c5;",
                                                            "**"		:"&#x2217;",
                                                            "***"		:"&#x22c6;",
                                                            "//"		:"/",
                                                            "\\\\"		:"\\",
                                                            "setminus"	:"\\",
                                                            "xx"		:"&#xd7;",
                                                            "-:"		:"&#xf7;",
                                                            "divide"	:"&#xf7;",		// RWW modified
                                                            "@"			:"&#x2218;",
                                                            "o+"		:"&#x2295;",
                                                            "ox"		:"&#x2297;",
                                                            "o."		:"&#x2299;",
                                                            "^^"		:"&#x2227;",
                                                            "vv"		:"&#x2228;",
                                                            "nn"		:"&#x2229;",
                                                            "uu"		:"&#x222a;",
                                                            "!="		:"&#x2260;",
                                                            "lt"		:"<",
                                                            "<="		:"&#x2264;",
                                                            "lt="		:"&#x2264;",
                                                            "gt"		:">",
                                                            ">="		:"&#x2265;",
                                                            "gt="		:"&#x2265;",
                                                            "-<"		:"&#x227a;",
                                                            "-lt"		:"&#x227a;",
                                                            ">-"		:"&#x227b;",
                                                            "-<="		:"&#x2aaf;",
                                                            ">-="		:"&#x2ab0;",
                                                            "in"		:"&#x2208;",
                                                            "!in"		:"&#x2209;",
                                                            "sub"		:"&#x2282;",
                                                            "sup"		:"&#x2283;",
                                                            "sube"		:"&#x2286;",
                                                            "supe"		:"&#x2287;",
                                                            "-="		:"&#x2261;",
                                                            "~="		:"&#x2245;",
                                                            "~~"		:"&#x2248;",
                                                            "prop"		:"&#x221d;",
                                                            "and"		:["<mrow><mspace width='1ex'/><mo>","and",
                                                                            "</mo><mspace width='1ex'/></mrow>"],
                                                            "or"		:["<mrow><mspace width='1ex'/><mo>","or",
                                                                            "</mo><mspace width='1ex'/></mrow>"],
                                                            "not"		:"&#xac;",
                                                            "=>"		:"&#x21d2;",
                                                            "if"		:["<mrow><mspace width='1ex'/><mo>","if",
                                                                            "</mo><mspace width='1ex'/></mrow>"],
                                                            "<=>"		:"&#x21d4;",
                                                            "AA"		:"&#x2200;",
                                                            "EE"		:"&#x2203;",
                                                            "_|_"		:"&#x22a5;",
                                                            "TT"		:"&#x22a4;",
                                                            "|--"		:"&#x22a2;",
                                                            "|=="		:"&#x22a8;",
                                                            "int"		:"&#x222b;",
                                                            "oint"		:"&#x222e;",
                                                            "del"		:"&#x2202;",
                                                            "grad"		:"&#x2207;",
                                                            "+-"		:"&#xb1;",
                                                            "O/"		:"&#x2205;",
                                                            "oo"		:"&#x221e;",
                                                            "aleph"		:"&#x2135;",
                                                            ":."		:"&#x2234;",
                                                            "/_"		:"&#x2220;",
                                                            "/_\\"		:"&#x25b3;",
                                                            "'"			:"&#x2032;",
                                                            "\\ "		:"&#xa0;",
                                                            "quad"		:"&#xa0;&#xa0;",
                                                            "qquad"		:"&#xa0;&#xa0;&#xa0;&#xa0;",
                                                            "cdots"		:"&#x22ef;",
                                                            "vdots"		:"&#x22ee;",
                                                            "ddots"		:"&#x22f1;",
                                                            "diamond"	:"&#x22c4;",
                                                            "square"	:"&#x25a1;",
                                                            "|__"		:"&#x230a;",
                                                            "__|"		:"&#x230b;",
                                                            "|~"		:"&#x2308;",
                                                            "~|"		:"&#x2309;",
                                                            "CC"		:"&#x2102;",
                                                            "NN"		:"&#x2115;",
                                                            "QQ"		:"&#x211a;",
                                                            "RR"		:"&#x211d;",
                                                            "ZZ"		:"&#x2124;",
                                                            "uarr"		:"&#x2191;",
                                                            "darr"		:"&#x2193;",
                                                            "rarr"		:"&#x2192;",
                                                            "->"		:"&#x2192;",
                                                            ">->"		:"&#x21a3;",
                                                            "->>"		:"&#x21a0;",
                                                            ">->>"		:"&#x2916;",
                                                            "|->"		:"&#x21a6;",
                                                            "larr"		:"&#x2190;",
                                                            "harr"		:"&#x2194;",
                                                            "rArr"		:"&#x21d2;",
                                                            "lArr"		:"&#x21d0;",
                                                            "hArr"		:"&#x21d4;"}[sym]
                                                        switch (typeof output) {
                                                            case "undefined": output = ["<mo>",sym,"</mo>"];break
                                                                              // no translate value, symbol is the output
                                                            case "string": output = ["<mo>",output,"</mo>"];break
                                                        }
                                                        return output
                                                    }

    greekSyms	:~ Delta | Gamma | Lambda | Omega | Phi | Pi | Sigma | Theta | Xi
    binarySyms	:~ [*]{1,3} | / (?: /|[_][\\]?) | \\ [\\ ] | ! (?: =|in) | : (?: =|[.]) | lt=? | <=>? | gt=? |
                    > (?: -=?|=) | int? | su[bp]e? | ~[=~|] | prop | setminus | xx | divide | - (?: :|<=?|=|lt) | @ |
                    o[+x.] | \^\^ | vv | nn | uu | and | or | not | if | =>? | AA | EE | TT | _[|]_ | [|] (?: --|==|__|~)
    miscSyms	:~ oint | del | grad | [+]- | O/ | oo | aleph | [.]{3} | ' | q?quad | [cvd]dots | diamond |
                    square | __[|] | CC | NN | QQ | RR | ZZ
    funcSyms	:~ sinh? | cosh? | tanh? | coth? | sech? | csch? | arc(?: sin|cos|tan) | exp |
                    log | ln | det | dim | mod | gcd | lcm | lub | glb
    arrowSyms	:~ [udrlh]arr | [rlh]Arr | ->>? | >->>? | [|]->


    derivative	:~ dx | dy | dz | dt			:: (df) => ["<mrow><mi>d</mi><mi>",df.substring(1),"</mi></mrow>"]

    letter 		:~ [A-Za-z]						:: (letter) => ["<mi>",letter,"</mi>"]

    escape 		:~ [\\]	  						:: () => []

    other 		:~ [^\x00-\x20\x7f-\x9f]		:: (char) => ["<mo>",char,"</mo>"]

