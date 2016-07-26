
@import x-markup.css

// definitions...

&           = metamark
()          = myword <div class='inset'>
@include    = include
@imbed      = imbedURL

// file type transforms..

.myw        = myword
.txt        = text <pre>

// simple standard HTML5 element names, inline prose is the default transform

:abbr           = <abbr>
:address        = <address>
:article        = myword <article>
:aside          = myword <aside>
:b              = <b>
:bdi            = <bdi>
:bdo            = <b>
:blockquote     = myword <blockquote>
:br             = <br/>
:button         = <button>
:cite           = <cite>
:code           = text <code>
:dl             = myword <dl>
:dd             = myword <dd>
:dt             = text <dt>
:del            = <del>
:dfn            = <dfn>
:div            = myword <div>
:em             = <em>
:footer         = myword <footer>
:h1             = <h1>
:h2             = <h2>
:h3             = <h3>
:h4             = <h4>
:h5             = <h5>
:h6             = <h6>
:header         = myword <header>
:hr             = <hr/>
:i              = <i>
:ins            = <ins>
:kbd            = text <kbd>
:li             = myword <li>
:legend         = <legend>
:mark           = <mark>
:ol             = myword <ol>
:p              = <p>
:pre            = text <pre>
:q              = <q>
:s              = <s>
:samp           = text <samp>
:small          = <small>
:span           = <span>
:strong         = <strong>
:style          = text <style scoped>
:sub            = <sub>
:sup            = <sup>
:table          = myword <table>
:td             = myword <td>
:th             = myword <th>
:tr             = myword <tr>
:u              = <u>
:ul             = myword <ul>
:var            = <var>
:wbr            = <wbr/>

// common light-weight markup.....

#       = <h1>
##      = <h2>
###     = <h3>
####    = <h4>
#####   = <h5>
######  = <h6>
*       = <em>
**      = <strong>
>       = myword <blockquote>
---     = <hr/>
-       = list <ul>
+       = list <ol>
`       = text <code>
=       = text <kbd>
~       = <u>
~~      = <s>
^       = <sup>
_       = <sub>
/       = text <pre>
//      = text <span hidden>
?       = <mark>

@       = linkURL
!       = imgURL

linkURL :: (content) => {
    var url = markit('text', content);
    return "<a href='"+url+"'>"+url+"</a>";
    }

imgURL :: (content) =>  "<img src='"+content+"'/>"

// id links...

@id = linkID
#id = isID <b>

linkID :: (content) => {
    var id = markit('text', content);
    return "<a href='#"+id+"'>"+id+"</a>";
    }

isID :: (content) => {
    var id = markit('text', content);
    return "<span id='"+id+"'>"+id+"</span>";
    }


// dl terms definition lists...

.terms = terms <dl class=terms>

terms :: (content) => {
    var dl = "";
    var dd = "";
    var lines = content.split('\n');
    for (var i=0; i<lines.length; i++) {
        var line = lines[i];
        if (!line) continue;
            if (!line.match(/^\s/)) { // no indent
            if (dd) { dl += "<dd>" + markit("myword",dd) + "</dd>"; }
            dd = "";
            dl += "<dt>" + markit("text",line) + "</dt>";
        } else { // indented..
            dd += line.trim()+'\n';
        }
    }
    if (dd) { dl += "<dd>" + markit("myword",dd) + "</dd>"; }
    return dl;
    }

// table array...

.array = array <table class=array>

array := row*                 :: (rows) => this.flatten(rows).join('')
    row   := tsep* cell* nl?  :: (_,cells) => (cells.length>0)? ["<tr>",cells,"</tr>"] : ''
    cell  := item tsep?       :: (item) => ["<td>",markit('prose',this.flatten(item).join('')),"</td>"]
    item  := (!delim char)+
    delim :~ %tsep | %nl
    tsep  :~ ([ ]*[\t]|[ ]{2,}) [ \t]*
    nl    :~ [\n\f]|([\r][\n]?)
    char  :~ [\s\S]

// iframe for imbed...

imbedURL :: (content) => {
    var url = markit('text', content);
    return "<iframe src='"+url+"' scrolling=no style='overflow:hidden; border:none; width:100%;'></iframe>";
    }

// useful document elements ......

.eg     = text <div class='eg'>

.demo   = demo <table class='demo'>

demo    :: (content) => {
            var html = markit('myword', content);
            return "<tr><td class='A1' contenteditable=true onkeyup='demoEdit(event)'>" +
                markit('text',content) +
                "</td><td class='B1'>" +
                html +
                "</td></tr><tr><td class='A2'>" +
                "<button onclick='demoHTML(event)'>HTML..</button>" +
                "</td></tr><tr><td class='A3' colspan=2 hidden>" +
                markit('text',html) +
                "</td></tr>"
            }
