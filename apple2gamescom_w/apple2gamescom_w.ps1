
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
$text1 = @"
#ca-talk {display:none}
li#n-Site-Search {display:none}
#p-tb {display:none}
#ca-viewsource {display:none}
#ca-history {display:none}
#p-personal {display:none}
#p-search {display:none}
"@
$text2 = @"
* empty section
* navigation
** Apple_2_Emulators|Apple II & IIe Emulators
** mainpage|mainpage-description
** Special:Categories|Categories
* Games
** Adventure|Adventure
** Arcade|Arcade
** Board Games|Board Games
** Fantasy & Role Playing|Fantasy & Role Playing
** Gambling & Card Games|Gambling & Card Games
** Miscellaneous|Miscellaneous
** Personal Entertainment|Personal Entertainment
** Puzzle & Strategy|Puzzle & Strategy
** Shoot-em-up|Shoot-em-up
** :Category:Sports Games|Sports
** Tactical Space Games|Tactical Space Games
** War Simulation|War Simulation
* SEARCH
* TOOLBOX
* LANGUAGES
"@
$text3 = @"
__NOTOC__<div style="border: 1px solid #fcf; background: #cccccc; padding: 0.5em 1em 0.5em 1em; font-weight: bold; text-align: center; margin-bottom: 0.5em;"><big>'''Welcome to Apple ][ Games'''</big> Currently there are [[Special:Statistics|{{NUMBEROFPAGES}}]] {{PAGENAME}} items in our Wiki.</div>
 
<div style='position: relative;'>
<!--Sub Page Portal Block Begin-->
{{/box-header|TITLE=Featured Game for April 2020 (Month 2 of quarantine [https://archive.org/details/TotalReplay '''Total Replay''']}}
[https://archive.org/details/TotalReplay '''Total Replay''']
[[File:total-replay-cover.png|thumb|40%|left|Total Replay attract sceen]]
OK not a single game this month... since we're all in quarantine and staying at home we'll need a few more games to play.  How 'bout over 200?  Total replay is work of 4am & qkumba who have been able to take over 200+ Apple 2 games and squeeze them into a single 32meg HDD image.  Total Replay is not just a bunch of games with a catalog of whats on the hard drive at boot, it's a whole game system with launcher!  Each game has a screen captutre and there are some amazing (for the Apple 2) graphic fade effects.  Total replay is open source and avaliable on GitHub if you're so inclined to look at the source code.  Total Replay works great on a CFFA 3000.  You will have to have 128K for same games that require it.  Total replay also works great in emulators.

Download Total Replay here ---> [https://archive.org/details/TotalReplay '''Total Replay''']


{{/box-footer|}}

</div> 
 


<big>'''== Looking for the [[Apple 2 Emulators]]? Check out the latest Apple II Emulators news here. '''</big>

<big>'''== Looking for the [[ASIMOV Incoming Folder Watch]] or [[ASIMOV Archive Uploads]]'''</big>


<big>'''== APPLE ][ EMULATOR NEWS =='''</big>

November 10, 2018 Little late to this party but there's a new emulation file format called WOZ. A WOZ file, named after Steve Wozniak (of course) is able to copy a full Apple ][ disk including software protection.  It is able to do this by recording the flux images and timings.  I'm still a bit unclear but a detailed refence page can be seen here. https://applesaucefdc.com/a2r/ 

As of right now WOZ files work with most emulators on the Mac.  On the PC/Linux however AppleWin & LinApple do not.  However, there is a NEW emulator called microM8 that WOZ files work with.  microM8 comes from paleotronic magazine out of Australia.  So far I'm very impressed with the version for Linux.  I downloaded this and was up and running in less than a minute.  Don't have every single image from Asimov already loaded onto your computer?  No worries, microM8 comes with a huge catalog of images you can download and run. Some extra bonuses with microM8 is the ready to run built in support for Applesoft Basic, Apple Integer Basic, and LOGO!  They have also included an emulator of Proterm which mimics a modem and allows you to connect to remote a BBS.  I'm still going through the help documentation for this emulator as there is quite a lot more here than just playing old image files!  This one is quickly becoming my favorite new thing especially on Linux(Ubuntu)!   

microM8 is avaiable for free from paleotronic magazine.  https://paleotronic.com/software/microm8/


Apple ][js and Apple //jse - An Apple ][ Emulator and Apple //e in JavaScript by Will Scullin.
https://www.scullinsteel.com/apple2/ A well done emulator programmed completely in in JavaScript making it compatable with just about every browser out there that can handle the modern Javascript scripting language. To check out Apple ][js go to https://www.scullinsteel.com/apple2/ and to play the Apple //jse  head over to https://www.scullinsteel.com/apple//e Whats great with both A][js & A//ejs is that both have a bunch of games and other assorted images bundeled in with them so no need to download & upload roms.  Both these emulators IMHO seem to run much better than the one on archive.org



February 17,2016 :: AppleWin v1.26.1.1 has been released.  New releases are now being tracked on GitHub (https://github.com/AppleWin/AppleWin) 

If you simply want to download the executable files for Windows (works great under Wine on Linux btw) visit https://github.com/AppleWin/AppleWin to download the newest compiled version thats ready to go.  Note the download link in the READ.ME section on GitHub.  I won't link directly to it since new versions can popup at any time.


<p>If you're here, you are more than likely familiar with the Apple 2 computer.  Apple hasn't produced this machine in over 30 years, but there is still a large user community supporting the machine.  However, if the Apple 2 is all new to you and the only thing Apple has produced that you know of is an iPod, then check out the [[Apple 2 Emulators]] page.  With one of these fine emulators you can bring the Apple 2 experience to your modern day machine.</p>

<P>From there, check out the games pages.  See why some old-time gamers still think this was one of the best computers for gaming.  I can play [[Apple Panic]] or [[Hard Hat Mack]] for a few days; yet can't play any of the new cutting edge 3D shooters for more than a few minutes without getting bored... not that I have time anymore with responsibilities as a parent.  Though the kids do like some of the old Sierra Online/Online Systems graphic adventures like [[The Wizard and the Princess]] and [[Mission: Asteroid]] and the Where in the World is Carmen Sandiego the king or Queen of all Edutainment software.</P>
  

<big>'''February 3, 2019 - Leaving GoDaddy and moving to Amazon S3'''</big>

<p>I have finally pulled the plug on Godaddy.  After 10+ years with the hosting service I've found that it is time to move on.  Several things lead me to this decision.  First and foremost my normal day job is spent almost entirely working with Amazon Web Services.  My companies sites, databases, data, images you name it are hosted with Amazon.  We couldn't be happier.  Second, PHP 5.3.X and PHP 7.0 have come to end of life and are no longer going to be supported or upgraded.  This is a problem since the server that Apple2games.com was on PHP 5.3.13 which ISN'T EVEN ON THE OFFICIAL PHP Supported Versions chart.  http://php.net/supported-versions.php  it's too old.  The most recent version of MediaWiki requires PHP 7.0 or later to run.  When ever I tried to update this on GoDaddy MediaWiki would fail and go into the WHITE PAGE OF DEATH mode.  Finally the scripts that I had built to walk through Asimov on a nightly basis broke at some point and I could never get them back up and running with the version of MediaWiki running at GoDaddy.  

So with all that said, this site is now running on Amazon S3.  There is no MediaWiki functionality in it.  

<big>'''June 10, 2018 - The Apple // turned 41. Happy 41st Birthday Apple //'''</big>


<p>Apple ][ games is a wiki dedicated to old school 8 bit Apple ][ computers games.  The [[Apple 2]] series of computers dominated the American home computing market during the 1980's and early 1990's.  From it's initial launch in 1977 to it's final manufacturing run, Apple computer sold millions of these machines.  Practically every school in the country had an [[Apple 2]] and it was the one with a ton of ''[[games]]'', too.</p>
<p>A vast majority of the videos (except for the Castle Wolfenstein walk through which I did the first time I sat down with the video screen cap and AppleWin) you'll find on this site come from "Old Classic Retro Gaming" a YouTube user you should subscribe to.  This is his channel: http://www.youtube.com/user/oldclassicgame and "Retro games history museum" here's their channel http://www.youtube.com/user/Highretrogamelord89</p>
<p>It wasn't until the Macintosh & Windows appeared on the market that the [[Apple 2]] started to drop in popularity. Today, there's still thousands of [[Apple 2]] computers out there in the wild and, on any given day, several can be found on eBay or Craigs List.  There is still a very strong and thriving programming community and several great emulators available.  Heck someone even created a [http://www.youtube.com/watch?v=bfjzI2bavxo&mode=related&search=:music video for the rock band Granddaddy using an Apple 2e] </p>






<big>'''== January  2, 2016... Asimov archive up again... '''</big>
Spent a few hours remuxing the API code for the scripts to post back & froth only to find that the USER name that I had created to replace the one I had deleted a few months ago (I guess back in July) had a TYPO in it.  Yeah.. so it's back up and running.

First new write up will be for the Wizard and the Princess since the kids have been playing this again.

<big>'''== December 31, 2016... Asimov archive down again... '''</big>

After upgrading Wikimedia (the software behind Apple II Games) the API broke.  Then in a total stupid WTF did I do that I deleted the API user account used for posting.  Basically I had over 80,000 spam accounts that have been created and trying to post crap on the site so I just said "delete from users where ID >1" well API user was #2 doh!  Anyhow... Wikimedia has once again changed some of the API calls and I've got to spend some time redoing it.  I'm writing this on a Chromebook so have no editing ability (that i know of) 

So '''resolutions for 2017'''... 
* Write up and post at least one new game a week.  If 4am can recrack three to 70 a week I can take the time to run & write up one a week.  
* Find a new power supply for the Apple IIe that died on me.
* Find a new work space for the machine since my son moved a Wii to it's old location (once said computer died)
* Use 4am's Passport to crack all the originals that I have.
* Restart a userforum  




Site Updates 2014-06-08 Woot Woot!  We're Mobile now with our new Mobile Aware WikiMedia Skin. :) We're mobile now if you care to browse the web with your cell phone or table.  Hopefully the site is looking better now with this update :) 

<big>'''== ASIMOV Archive Updates =='''</big>

2014-05-31 Having as much data as Asimov does it was a real temptation to slice & dice it and generate a few stats & charts.  So what better thing to do on a beautiful sunny day in Cleveland than parse some data.  [[Asimov Apple 2 Archive Stats]] Favorite chart out of this little project is the word cloud... CRACK
 
2014-05-30 Was able to carve out enough time to totally rewrite the Asimov archive watch.  It is now based of FTP code rather than pulling & parsing the daily index.  As such I have been able to parse the whole archive and get a historical view of all uploads... plus as new things come online they'll first show up in the incoming folder & incoming page ([[ASIMOV Incoming Folder Watch]]) and then when they're moved to the final path they'll show up here [[ASIMOV Archive Uploads]]

2014-05-26 (Last couple hours of memorial day) I've been able to rewrite the code to get past the firewall issue.  Also have created a new [[ASIMOV Incoming Folder Watch]] page which doesn't have links to download but watches what is being uploading.  Hope to have the old Asimov Update page back up ... but with a bit more detail in dates & without all the duplicates.

2014-05-25 Came to my attention today that outgoing connects from our server are being fire walled so Asimov updates haven't been updated since mid April.  I'm working on a new solution now.


I've created a bot which will parse the ASIMOV archive index file and post any changes that it finds on this page [[ASIMOV Updates]]  Currently the bot does it's magic every few hours and creates a section for each day.  In this section will be the direct links to the new files that have been uploaded OR changed.  The bot spotted a huge number of files on ASIMOV that had been changed.  Looks like someone Gunzipped 800+ files.


== Games ==

* [[Adventure]]
* [[Arcade]]
* [[Board Games]]
* [[Fantasy & Role Playing]]
* [[Gambling & Card Games]]
* [[Miscellaneous]]
* [[Personal Entertainment]]
* [[Puzzle & Strategy]]
* [[Shoot-em-up]]
* [[:Category:Sports Games]]
* [[Tactical Space Games]]
* [[War Simulation]]

== Apple 2 Sites ==

* [[Game Related]]
* [[Apple 2 Emulators]]
* [[Apple 2 News Sites]]
"@



Edit-Page 'MediaWiki:Common.css' $summary $text1
Edit-Page 'MediaWiki:Sidebar' $summary $text2
Edit-Page 'Main_Page' $summary $text3

Invoke-Logout
