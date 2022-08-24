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
[[File:12-monkeys-wiki-about.png|center|link=]]
'''''[[12 Monkeys]]''''' is an American science fiction series that first aired on the Syfy channel. It is based in part on the movie by the same name which, in turn, was partially based on a short French film entitled La Jetée.

In the series, ninety-eight percent of the world population is killed by the Kalavirus, and time-traveler James Cole was sent back from 2043 to prevent the plague masterminded by the Army of the 12 Monkeys. ''[[12 Monkeys | Read more]]''...
<br />
[[File:Character-gallery.png|center|link=]]


<center>
<gallery position="center" orientation="none" hideaddbutton="true" captionalign="center" captionposition="within" bordercolor="#3c3c3c" captiontextcolor="#ffffff" navigation="true" widths="110" spacing="small" bordersize="medium">
ColeS2.jpg|[[James Cole]]|link= James Cole
CassieS2.jpg|[[Cassandra Railly]]|link= Cassandra Railly
RamseS2.jpg|[[Jose Ramse]]|link= Jose Ramse
JenniferS2.jpg|[[Jennifer Goines]]|link= Jennifer Goines
JonesS2.jpg|[[Katarina Jones]]|link= Katarina Jones
DeaconS2.jpg|[[Theodore Deacon]]|link= Theodore Deacon
</gallery>
</center>
<br />
<div style="width:60%;margin:auto;">
{{Navbox Season 4}}
{{Navbox Season 3}}
{{Navbox Season 2}}
{{Navbox Season 1}}
</div>
</div>

[[Category:Browse]]

"@


Edit-Page 'MediaWiki:Citizen-footer-desc' $summary $text1
Edit-Page 'MediaWiki:Citizen-footer-tagline' $summary $text1
Edit-Page 'MediaWiki:Privacy' $summary $text2
Edit-Page 'MediaWiki:Aboutsite' $summary $text2
Edit-Page 'MediaWiki:Disclaimers' $summary $text2
Edit-Page 'MediaWiki:Common.css' $summary $text3
Edit-Page '12_Monkeys_TV_Series_Wiki' $summary $text4

Invoke-Logout

