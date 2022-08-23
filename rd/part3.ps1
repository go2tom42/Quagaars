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
$text1 = ''
$text2 = '-'
$text3 = @"
.mw-footer { display: none; }
.mw-list-item#n-recentchanges { display:none}
.mw-list-item#n-randompage { display:none }
.mw-list-item#n-help-mediawiki { display:none }
.mw-list-item#t-specialpages { display:none }
.mw-list-item#t-upload { display:none }
.mw-portlet-coll-print_export { display:none }
.citizen-search__buttonIcon { display:none }
#citizen-personalMenu__buttonCheckbox { display:none }
.citizen-search__button { display:none }
"@


$text4 = @"
[[File:RD Welcome.png|center|link=]]
<center>'''[[Tongue Tied:About|Tongue Tied]] is a collaborative project to create the most definitive, accurate, and accessible encyclopedia and reference database for everything related to ''[[Red Dwarf]]'''''.</center><br />
[[File:Tongue-tied-needs-you.png|center|link=]]
<center>'''Tongue Tied needs you to help contribute to our articles. [[:Category:Browse|Start exploring!]]'''</center>
<center><small>This wiki was started 7 November 2006. There are currently '''[[Special:Statistics|{{NUMBEROFARTICLES}} articles]]''' and '''[[Special:Newimages|{{NUMBEROFFILES}} images]]'''.<br />Today is {{CURRENTDAY}} {{CURRENTMONTHNAME}}, {{CURRENTYEAR}}.</small></center>
<center>'''''"This is an S.O.S. distress call from the [[Jupiter Mining Corporation|mining ship]] [[Red Dwarf (ship)|Red Dwarf]]. The crew are dead, killed by a [[Cadmium II|radiation leak]]. The only survivors are [[Dave Lister]], who was in [[Stasis|suspended animation]] during the disaster, and his [[Frankenstein |pregnant cat]], who was safely sealed in the hold. Revived three million years later, Lister's only companions are a [[Cat|life-form who evolved from his cat]], and [[Arnold Rimmer]], a [[hologram]] simulation of one of the dead crew. Message ends."'''''<br />-[[Holly]] ([[Series I]])</center>
<center>
{|class="wikitable mw-collapsible  mw-collapsed";
|+ style="margin-left: auto; margin-right: auto; border: none; width: 1080px; text-align: center;" | Series I - IV
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_I|Series I]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_II|Series II]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_III|Series III]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_IV|Series IV]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_The End|The End]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Kryten|Kryten]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Backwards|Backwards]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Camille|Camille]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Future Echoes|Future Echoes]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Better Than Life|Better Than Life]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Marooned|Marooned]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_D.N.A.|D.N.A.]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Balance of Power|Balance of Power]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Thanks for the Memory|Thanks for the Memory]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Polymorph|Polymorph]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Justice|Justice]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Waiting for God|Waiting for God]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Stasis Leak|Stasis Leak]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Bodyswap|Bodyswap]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_White Hole|White Hole]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Confidence and Paranoia|Confidence and Paranoia]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Queeg|Queeg]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Timeslides|Timeslides]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Dimension Jump|Dimension Jump]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Me²|Me²]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Parallel Universe|Parallel Universe]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_The_Last_Day|The Last Day]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Meltdown|Meltdown]]
|}
</center>
<center>
{|class="wikitable mw-collapsible  mw-collapsed";
|+ style="margin-left: auto; margin-right: auto; border: none; width: 1080px; text-align: center;" | Series V - VIII
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_V|Series V]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_VI|Series VI]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_VII|Series VII]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_VIII|Series VIII]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Holoship|Holoship]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Psirens|sirens]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Tikka_To_Ride|Tikka To Ride]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Back_in_the_Red_I|Back in the Red I]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_The_Inquisitor|The Inquisitor]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Legion|Legion]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Stoke_Me_a_Clipper|Stoke Me a Clipper]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Back_in_the_Red_II|Back in the Red II]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Terrorform|Terrorform]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Gunmen_of_the_Apocalypse|Gunmen of the Apocalypse]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Ouroboros|Ouroboros]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Back_in_the_Red_III|Back in the Red III]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Quarantine|Quarantine]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Emohawk|Emohawk]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Duct_Soup|Duct Soup]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Cassandra|Cassandra]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Demons_%26_Angels|Demons &amp; Angels]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Rimmerworld|Rimmerworld]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Blue|Blue]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Krytie_TV|Krytie TV]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Back_To_Reality|Back To Reality]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Out_Of_Time|Out of Time]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Beyond_a_Joke|Beyond a Joke]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Pete_I|Pete I]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Epideme|Epideme]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Pete_II|Pete II]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Nanarchy|Nanarchy]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Only_The_Good...|Only The Good...]]
|}
</center>
<center>
{|class="wikitable mw-collapsible  mw-collapsed";
|+ style="margin-left: auto; margin-right: auto; border: none; width: 1080px; text-align: center;" | Series X - Movies
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_X|Series V]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_XI|Series VI]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |[[Series_XII|Series VII]]
! style="border:1px solid red; width: 260px; text-align: center; padding: .2% 1% .2% 1%;" |Movies
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Trojan|Trojan]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Twentica|Twentica]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Cured|Cured]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[Back_to_Earth|Back To Earth (as Series IX)]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Fathers_%26_Suns|Fathers &amp; Suns]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Samsara|Samsara]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Siliconia|Siliconia]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[The_Promised_Land|The Promised Land]]
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Lemons|Lemons]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Give_%26_Take|Give &amp; Take]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Timewave|Timewave]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Entangled|Entangled]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Officer_Rimmer|Officer Rimmer]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Mechocracy|Mechocracy]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Dear_Dave|Dear Dave]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Krysis|Krysis]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_M-Corp|M-Corp]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
|-
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_The_Beginning|The Beginning]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Can_of_Worms|Can of Worms]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |[[RD:_Skipper|Skipper]]
| style="border:1px solid red; padding: .2% 1% .2% 1%;" |-
|}
</center>
"@

$text5 = @"
[[File:Wiki.png|thumb|right|Tongue Tied logo]]
'''Tongue Tied''' is a free ''[[Red Dwarf]]'' reference website that is being written collaboratively by the readers. Our goal is to become the largest, most reliable, and most up-to-date encyclopedia about everything related to the Red Dwarf universe, presenting topics as they might appear if accessed in-universe, that is as the Red Dwarf universe was real. 
'''Tongue Tied''' is a '''Wiki''', meaning that any fan may edit any article by clicking on the edit this page link that appears in every wiki article that is not designated as a protected page. This makes it very easy for any fan to share their knowledge and insight of the Red Dwarf universe and add to the collected information available.
The project was started in November 2006, by [[User:Pete Valle | Pedro C. Valle Javier]]    a Red Dwarf fan from [[wikipedia:San Juan|San Juan]], [[wikipedia:Puerto Rico|Puerto Rico]]. The Wiki is currently being administrated by [[User:Roland The Headless Thompson Gunner|Hamish Wilson]] and [[User:Technopeasant| Graham Wilson]] of [[wikipedia:Seba Beach|Seba Beach]], [[wikipedia:Canada|Canada]].
The project was inspired by [[Wikipedia:Main Page| Wikipedia]], a free and open encyclopedia, and especially our "sister projects": [[MemoryAlpha:Main Page|Memory Alpha]], a wiki reference site devoted to the '''Star Trek''' universe, [[Tardis:Main Page|TARDIS Index File]], a wiki reference dedicated to '''Doctor Who''', and [[Starwars:Main Page|Wookiepedia]], a wiki reference dedicated to the '''Star Wars''' Universe.  
There are many articles that may be worked on by [[Dwarfer| Dwarfers]] to help our database grow!
== More About Tongue Tied ==
*[[Tongue Tied]], an article about the project's namesake.
== Exploring Tongue Tied ==
*[[Special:Recentchanges | Recent changes]], see articles that are being worked on right now.
*[[Special:Allpages | All pages]] listed by title
*[[Special:Randompage | Random page ]], Go to a random page.
*[[Special:Newpages | New pages]], latest contributions to the project.
*[[Special:Popularpages | Popular pages]]
== Contributing to Tongue Tied ==
*[[Help:Contents | Help]] on editing articles and more.
*[[Forum:Starbug| Starbug]], The '''Tongue Tied''' discussion page.
== General Information on Wikis ==
Wiki building can be a fun, productive experience. Feel free to browse the links below for more info on wikis.
*[[Wikipedia:Wikipedia:About|Wikipedia: About]]
*[[Wikipedia:Wikipedia:Why Wikipedia is so great|Why Wikipedia is so great]] 
*[[Wikipedia:Wikipedia:Why Wikipedia is not so great|Why Wikipedia is not so great]] 
*[[Wikipedia:Wikipedia:Replies to common objections|Wikipedia: Replies to common objections]], a collection of counter arguments for common objections to the Wikipedia and wiki concept.
*[http://c2.com/cgi/wiki?WhyWikiWorks WhyWikiWorks], a discussion about the wiki concept at the original WikiWikiWeb
*[http://c2.com/cgi/wiki?WhyWikiWorksNot WhyWikiWorksNot], a discussion about the problems with the wiki concept at the original WikiWikiWeb

==More Red Dwarf Links ==

Other sites with information on ''Doctor Who'':

*[[Wikipedia:red Dwarf | Wikipedia article on the ''Red Dwarf'' series]]
*[http://www.bbc.co.uk/comedy/reddwarf/ BBC Official Site]
*[http://www.reddwarf.co.uk/ The Official Site]
*[http://www.reddwarffanclub.com/ The Official Fan Club]

== Copyright Information ==
"Red Dwarf" and all related names and characters are trademark and copyright of Grant Naylor Productions LTD.  The content of copyrighted websites are the property of their respective creators. This site is no way intended to infringe upon any copyright or trademark. All contributors are expected to refrain from submitting copyrighted work without permission or which exceeds the definitions of fair dealing (UK, Australia, and Canada) or fair use (United States) provisions of copyright law. Please consult the Wikipedia articles on fair dealing and fair use for a better understanding of these terms.
Articles which are found or believed to be an infringement of copyright will have the body text removed, and said page may be protected from further edits until the matter has been resolved. The legal owners of any image or other file used on this site may request the removal of said materials at any time.
All material appearing on '''Tongue Tied''' that is not previously copyrighted is available for distribution under the GNU Free Documentation License. Material taken from this site should also be available for distribution under said license and should carry a notice to that effect. All contributors are hereby informed that their submissions may be edited, moved, or deleted by others. This wiki's policy is to protect pages from editing only in cases of vandalism.
"@

Edit-Page 'Tongue_Tied:About' $summary $text5
Edit-Page 'MediaWiki:Citizen-footer-desc' $summary $text1
Edit-Page 'MediaWiki:Citizen-footer-tagline' $summary $text1
Edit-Page 'MediaWiki:Privacy' $summary $text2
Edit-Page 'MediaWiki:Aboutsite' $summary $text2
Edit-Page 'MediaWiki:Disclaimers' $summary $text2
Edit-Page 'MediaWiki:Common.css' $summary $text3
Edit-Page 'Main_Page' $summary $text4

Invoke-Logout

