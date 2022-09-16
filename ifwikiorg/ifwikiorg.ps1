
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
<div style="font-family: Times New Roman; text-align: center">
<span style="font-size: 1.5rem">''Welcome to the Interactive Fiction Wiki''</span>
<br/><span style="font-size: 1.2rem">''{{CURRENTDAYNAME}}, {{CURRENTMONTHNAME}} {{CURRENTDAY}}, {{CURRENTYEAR}}''</span>
</div>

IFWiki is an encyclopedia of [[interactive fiction]], including IF [[Theory#History|history]], [[theory]], [[craft]], [[:Category:Software|tools]], and [[:Category:People|people]]. IFWiki serves as both a historical record of community knowledge and a guide to resources for playing and creating interactive fiction.
{{Main announcement}}

<div class="responsive-container">
<div class="responsive-column-1">
==News==
{{Main Page News}}
==Events and competitions==
{{Main Page events}} 

==Software Updates==
{{software latest}}
</div>
<div class="responsive-column-2">
==Feature of the Day==
{{#lsth:IFWiki:Main Page features|{{CURRENTDAY}} }}
==FAQ==
* [[FAQ#What_is_.22interactive_fiction.22.3F|What is "interactive fiction"?]]
* [[FAQ#How_can_I_download_and_play_IF.3F|How can I download and play IF?]]
* [[FAQ#Where_can_I_find_out_what_games_I_might_enjoy.3F|Where can I find out what games I might enjoy?]]
* [[FAQ#Where_can_I_talk_with_other_people_who_are_into_IF.3F|Where can I talk with other people who are into IF?]]
([[FAQ|See all frequently asked questions]])

==Check out these articles!==
* See [[Craft]] for how-to articles.
* See [[Theory]] for articles on IF concepts.
* See [[Starters]] if you're new to IF.
* Annual competitions like [[IF Comp]], [[Spring Thing]], and the [[XYZZY Awards]].
* [[Parser-based]] authoring tools like [[ADRIFT]], [[Dialog]], [[Inform 6]], [[Inform 7]] and [[TADS 3]].
* [[Choice-based]] authoring tools like [[ChoiceScript]], [[Ink]] and [[Twine]].
* [[parser/choice hybrid|Hybrid]] authoring systems like [[Quest (Language)|Quest]].
* Retro-style parser authoring tools like [[Adventuron]], [[PunyInform]] and [[ZIL]].

==Contribute!==
You want to help edit the IFWiki? Great!

* Check out the [[IFWiki:Community portal|community portal]] for an overview.
* Read [[Help:Contents]] if you're new to editing wikis like ours.

You want to make a donation too?

[[Image:Iftf-logo.png|x80px|frameless|left|link=https://iftechfoundation.org/|alt=IFTF]] IFWiki is a service of the [https://iftechfoundation.org/ Interactive Fiction Technology Foundation]. It is supported by [http://iftechfoundation.org/give/ the donations of IF supporters like you].

</div>
</div>

__NOTOC__
__NOEDITSECTION__
"@



Edit-Page 'MediaWiki:Common.css' $summary $csstext
# Edit-Page 'MediaWiki:Sidebar' $summary $sidebartext
Edit-Page 'Main_Page' $summary $mainpagetext

Invoke-Logout
