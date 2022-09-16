
Add-Type -AssemblyName System.Web

$protocol = 'http://'
$wiki = '192.168.1.18/'
$api = 'api.php'
$username = 'user'
$password = 'pPtKYBSJVXb6'

$csrftoken
$websession
$wikiversion



function Edit-Page($title, $summary, $text) {
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'edit'
    $body.format = 'json'
    $body.bot = ''
    $body.title = $title
    $body.summary = $summary
    $body.text = $text
    $body.token = Get-CsrfToken

    $object = Invoke-WebRequest $uri -Method Post -Body $body -WebSession (Get-WebSession)
    $json = $object.Content
    $object = ConvertFrom-Json $json

    if ($object.edit.result -ne 'Success') {
        throw('Error editing page:' + $object + ',' + $object.error)
    }
}

function Get-WebSession() {
    if ($websession -eq $null) {
        Invoke-LogIn $username $password
    }
    return $websession
}

function Invoke-Login($username, $password) {
    $uri = $protocol + $wiki + $api

    $body = @{}
    $body.action = 'login'
    $body.format = 'json'
    $body.lgname = $username
    $body.lgpassword = $password

    $object = Invoke-WebRequest $uri -Method Post -Body $body -SessionVariable global:websession
    $json = $object.Content
    $object = ConvertFrom-Json $json

    if ($object.login.result -eq 'NeedToken') {
        $uri = $protocol + $wiki + $api

        $body.action = 'login'
        $body.format = 'json'
        $body.lgname = $username
        $body.lgpassword = $password
        $body.lgtoken = $object.login.token

        $object = Invoke-WebRequest $uri -Method Post -Body $body -WebSession $global:websession
        $json = $object.Content
        $object = ConvertFrom-Json $json
    }
    if ($object.login.result -ne 'Success') {
        throw ('Login.result = ' + $object.login.result)
    }
}
function Get-CsrfToken() {
    if ($csrftoken -eq $null) {
        $uri = $protocol + $wiki + $api

        if ((Get-Version) -lt '1.24') {
            $uri = $protocol + $wiki + $api

            $body = @{}
            $body.action = 'query'
            $body.format = 'json'
            $body.prop = 'info'
            $body.intoken = 'edit'
            $body.titles = 'User:' + $username

            $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
            $json = $object.Content
            $object = ConvertFrom-Json $json

            $pages = $object.query.pages
            $page = ($pages | Get-Member -MemberType NoteProperty).Name
            $csrftoken = $pages.($page).edittoken
        }
        else {
            $body = @{}
            $body.action = 'query'
            $body.format = 'json'
            $body.meta = 'tokens'
            $body.type = 'csrf'

            $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
            $json = $object.Content
            $object = ConvertFrom-Json $json

            $csrftoken = $object.query.tokens.csrftoken
        }
    }

    return $csrftoken
}
function Get-Version() {
    if ($wikiversion -eq $null) {
        $uri = $protocol + $wiki + $api

        $body = @{}
        $body.action = 'query'
        $body.format = 'json'
        $body.meta = 'siteinfo'
        $body.siprop = 'general'

        $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
        $json = $object.Content
        $object = ConvertFrom-Json $json

        $wikiversion = $object.query.general.generator
        $wikiversion = $wikiversion -replace 'MediaWiki ', ''
    }

    return $wikiversion
}
function Invoke-Logout() {
    $uri = $protocol + $wiki + $api
    
    $body = @{}
    $body.action = 'logout'
    $body.format = 'json'

    $object = Invoke-WebRequest $uri -Method Get -Body $body -WebSession (Get-WebSession)
}

$summary = ''

$csstext = @"
#p-Navigation {display:none}
#p-tb {display:none}
#p-personal {display:none}
#p-search {display:none}
#p-cactions {display:none}
#p-Help_and_Feedback {display:none}
#p-lang {display:none}
"@


$sidebartext = @"
"@



$mainpagetext = @"
<!-- Welcome -->
<div id="main page-welcome" class="main page-up" align="center">
{{Portal Title | Title=Welcome to the C64-Wiki | Info=The [[C64-Wiki]] is a project to build a special '''[[C64]] encyclopedia'''. Everybody is welcome to contribute to it.
At the moment there are '''[[Special:Allpages|{{NUMBEROFARTICLES}} articles]]''' of various [[Special:Mostlinkedcategories|topics]]. [[welcome|Authors wanted]].<br />
There are [[:Category:To-do|'''{{ #expr:{{PAGESINCATEGORY:To-do}}+{{PAGESINCATEGORY:Idea}}-17-2}} articles''']] under construction and [[Special:Wantedpages|'''{{User:Jodigi/RedLinks}} articles''']] wanted.
<!-- ''<div style="color:#0000FF;">Countdown to the 1000th article: '''{{ #expr:1000-{{NUMBEROFARTICLES:R}}+{{PAGESINCATEGORY:To-do:R}}-12 }}'''</div> '' // -->
}}
<!-- Start Blue Border -->
<div class="inhalt" style="border-bottom: 1px solid #dfdfdf">
<!-- Navigationsleiste Themen -->
<!-- navigation bar of topics -->
{{Portal-Navigations}}
<div style="margin: 2px 0px 2px 0px; padding: 2px 2px 2px 2px; border: 2px solid #CCCCFF; background-color:#FFFFFF; overflow:hidden; position: relative;" align="left">
{| width="100%" style="background-color: #FFFFFF;"
|-
<!-- START: Box links, zweispaltiges Layout -->
|style="vertical-align:top" |
<div style="margin: 2px 2px 2px 2px; border: 2px solid #DFDFDF; background-color:#F8F8F8;">
<div style="padding: 0.3em 1em 0.7em 1em;">
'''News &#8230;'''<br />
----
<!-- extended News -->
{{:Main Page/News}}
</div>
</div>

<!-- zweispaltiges Layout rechts -->
<!-- double column left -->

| width="45%" style="vertical-align:top; background-color: #FFFFFF;" |

<!-- START: Picture-Box -->
<!-- <div style="vertical-align:middle; margin: 2px 2px 2px 2px;  border: 2px solid #DFDFDF; padding: 0em 1em 1em 1em; background-color: #FFFFF8;" class="center" valign="middle"> // -->
<div style="margin: 2px 2px 2px 2px; padding: 0em 1em 1em 1em; border: 2px solid #DFDFDF; background-color:#FFFFF8; vertical-align:middle;">	
'''Already seen?'''
{|class="center" style="background-color: #FFFFCC;"
 |class="center" style="background-color: #FFFFDD;"|&nbsp;<br /><RandomImage>center|300px|@CTH@MainPage1@86400@0</RandomImage>
 |-
 |class="center"|<small>Random Image.</small>
 |}
</div>
<!-- END: Picture Box -->

<!-- START: Box Survey Umfrage -->
<div style="margin: 2px 2px 2px 2px; padding: 0em 1em 1em 1em; border: 2px solid #DFDFDF; background-color:#FFFFF8; vertical-align:middle;">	
'''Current Survey:'''
{{:Main Page/Survey}}
</div>
<!-- ENDE: Box Survey Umfrage -->

<!-- START: Box Wanted Article -->
<div style="margin: 5px 2px 2px 2px; padding: 0em 1em 1em 1em; border: 2px solid #DFDFDF; background-color:#FCFCFC;">

<!-- START: Box Newest Article -->
<div style="margin: 5px 5px 0px 0px; padding: 0em 1em 1em 1em; border: 2px solid #DFDFDF; background-color:#FFFFFF;">

'''Newest articles''' (assortment):<font size="6" class="plainlinks"> [{{fullurl:{{FULLPAGENAME}}/Newest_articles|action=edit}} &#9998;] </font><br />
<!-- extended Newest articles -->
{{:Main Page/Newest articles}}
<div style="text-align: right;"><small>'''All [[Special:Newpages|new articles]]'''</small></div>
</div>
----
<p style="text-align: center">Please use our '''[[Portal:Games]]''' when creating '''new game articles'''!<br/>
'''Templates''' are listed at '''[[:Category:Template|Category:Template]]'''.</p>
----
{| align="right" valign="top" style="background-color:#FCFCFC;"
 | 
 |}
'''Authors wanted for new articles.'''<font size="6" class="plainlinks"> [{{fullurl:{{FULLPAGENAME}}/Wanted_articles|action=edit}} &#9998;] </font>

For the following '''articles''', '''authors''' and '''information''' are wanted:
<!-- extended Wanted articles -->
{{:Main Page/Wanted articles}}
Feel free to click and write...

<div style="text-align: right;"><small>'''Other [[Special:Wantedpages|wanted pages]]'''</small></div>
<div style="text-align: right;"><small>'''[[Special:WhatLinksHere/Template:Stub1|Very short articles]]'''</small></div>

</div>

<!-- START: Highscormaster - Top 5 -->
<div style="margin: 5px 2px 2px 2px; border: 2px solid #BBDDBB; padding: 0.6em; background-color:#F8FFF8;">
'''[[C64-Wiki:Highscoremaster|Highscoremaster]] of C64-Wiki (TOP5)''' 
{| {{Wikitable}}
 !<small>Place</small>!!<small>User</small>!!<small>Points</small>!!<small>1st place<br/> each 10 points</small>!!<small>2nd place<br/> each 6 points</small>!!<small>3rd place<br/> each 2 points</small>!!<small>further places <br/> each 1 points</small>!!<small>number of games</small>
 |-
 | 1 || Ivanpaduano || 1098 || 89 || 20 || 15 || 58 || 182
 |-
 | 2 || Robotron2084 || 939 || 41 || 64 || 48 || 49 || 202
 |-
 | 3 || Werner || 816 || 35 || 46 || 46 || 98 || 225
 |-
 | 4 || Camailleon || 516 || 28 || 25 || 21 || 44 || 118
 |-
 | 5 || TheRyk || 477 || 11 || 31 || 51 || 79 || 172
 |}
[[C64-Wiki:Highscoremaster|Table with all highscore entries]].

This table was assembled on 18th January 2022 by [[User:Werner|Werner]].
It is based on [[User:Robotron2084|Robotron2084's]] idea and was coordinated in detail on [http://www.forum64.de/wbb3/board2-c64-alles-rund-um-den-brotkasten/board179-c64-wiki/38181-highscoremaster-tabelle-f-rs-wiki/ Forum64.de].
</div>
<!-- ENDE: Highscormaster - Top 5 -->

<div style="margin: 5px 2px 2px 2px; border: 2px solid #BBDDBB; padding: 0.6em; background-color:#FCFCFC;">
<!--{| {{Boxa}}
 |//-->
{{:Main Page/Statistic}}
<!--|} //-->
</div>

|}

<div style="text-align:center; margin: 5px 5px 2px 5px; padding: 3px 3px 3px 3px; background-color: #F8FFFF; border: 1px solid #DFDFDF;">
'''[[Special:Newpages|New pages]] · [[Special:Newimages|New images]] · [[Special:Statistics|Statistics]] · [[:Category:C64-Wiki|Important for the wiki]]'''</div>

<div style="text-align:center; margin: 5px 5px 5px 5px; padding: 3px 3px 3px 3px; background-color:#FFF8FF; border: 1px solid #DFDFDF;">'''[[C64-Wiki:Administrators|List of administrators]] · [[Special:Listusers|List of users]] · [[C64-Wiki:Forum|Forum]]</div>

</div>

<div style="margin: 5px 0px 5px 0px; border: 2px solid #000; padding: 0em 1em 1em 1em; background-color:#dddddd;" align="left">


'''Did you know...?'''


*the '''sources''' of protected articles can be copied and used as blue print for your own articles.

*'''Create an own account''' if you want to use '''all features''' (e.g. "image upload", "watchlist for articles") and if you want an '''own user page'''.

</div>

{|align="center" padding="0" cellspacing="0" width="100%" style="background-color: #f8f8f8; border: 0;"
 |align="center"|<RandomImage>center|300px|@CTH@MainPage2@86400@0</RandomImage>
 |align="center"|<RandomImage>center|300px|@CTH@MainPage3@86400@0</RandomImage>
|}

{|align="center" padding="0" cellspacing="0" width="100%" style="background-color: #f8f8f8; border: 0;"
 !align="center"|The TOP GAMES of the [[C64-Wiki]]
 |- 
 |class="center"|<SimpleVote>top-3</SimpleVote>
 |-
 |align="center"|<small>'''&gt; [[C64-Wiki:Golden Games|TOP-10]]&nbsp;&middot;&nbsp;[[C64-Wiki:TOP100|TOP-100]]&nbsp;&middot;&nbsp;[[C64-Wiki:FLOP|FLOP-100]]&nbsp;&middot;&nbsp;[[C64-Wiki:NOV|NOV]]''' &lt;</small><br/>
|}

</div>
__NOTOC__
__NOEDITSECTION__
<Banner></Banner>
"@



Edit-Page 'MediaWiki:Common.css' $summary $csstext
# Edit-Page 'MediaWiki:Sidebar' $summary $sidebartext
Edit-Page 'Main_Page' $summary $mainpagetext

Invoke-Logout
