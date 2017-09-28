<?php
/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
*/

/* Version 1430123388 */


//File containing banned id's (read AND write permissions required unless $allowremote is true)
//ex. './bannedIDs.txt', './banned_user.cfg', 'http://example.com/banlist.txt'
$idlist = './banned_user.cfg';

//Allow remote list locations (disable the need for write permissions)
//Note: If you enable this you MUST end the file in atleast a newline
//character or preferrably something like //end otherwise the last
//Steam ID on the list will be ignored!
$allowremote = false; //true or false

//Ban STEAM_ID_PENDING, STEAM_ID_LAN, VALVE_ID_PENDING, VALVE_ID_LAN?
$banpending = false; //true or false

//Disable Steam ID validity checking (NOT RECOMMENDED)
//Only do this if you are getting _INVALID on ID's you're 100% sure are valid
//Note: Disabling validity checking will also force $banpending to false. If
//you want to keep STEAM_ID_PENDING for example banned with validity cheking
//disabled you will have to add it to your banlist.
$noval = false; //true or false

//Enable PHP error messages for debugging reasons, otherwise just print _ERROR on errors
$enabledebug = false; //true or false


//Don't edit below unless you know what you're doing!
function myErrorHandler($errno, $errstr, $errfile, $errline)
{
	if (!(error_reporting() & $errno)) {
		return;
	}

	switch ($errno) {
	default:
		echo '_ERROR';
		exit(1);
		break;
	}
	
	return true;
}

if ($enabledebug == false) {
	set_error_handler("myErrorHandler");
}

if (isset($_GET['id'])) {
	$id = $_GET['id'];
} else {
    $id = '';
}
if ($id == '') {
	$id = 'empty';
}

if ($noval == false) {
	if (strpos($id, '_ID_PENDING') !== false && strlen($id) < 17 || strpos($id, '_ID_LAN') !== false && strlen($id) < 13) {
		if ($banpending == true) {
			echo '_BAN';
			exit;
		} else {
			echo '_OK';
			exit;
		}
	}
	if (strpos($id, 'STEAM_') === false || is_numeric(substr($id, 10)) == false || strpos(substr($id, 10), '.') !== false || strlen($id) > 24) {
		echo '_INVALID';
		exit;
	}
}

$id = preg_replace('/^STEAM_[0-9]:/i', '', $id);

$banned = false;
if ($allowremote == false) {
	$handle = @fopen($idlist, 'r+t');
	if ($handle) {
		fseek($handle, 0);
		if (strpos(fgets($handle), "\r\n") !== false) {
			$linebreak = "\r\n";
			fseek($handle, -2, SEEK_END);
		} else {
			$linebreak = "\n";
			fseek($handle, -1, SEEK_END);
		}
		if (strpos(fgets($handle), $linebreak) === false) {
			fwrite($handle, $linebreak);
		}
		fseek($handle, 0);
		while (($line = fgets($handle)) !== false) {
			if (strpos($line, $id . $linebreak) !== false) {
				$banned = true;
				break;
			}
		}
	} else {
		trigger_error("Unable to open file ($idlist) for reading and writing", E_USER_ERROR);
	}
	fclose($handle);
} else {
	$handle = @fopen($idlist, 'rt');
	if ($handle) {
		if (strpos(fgets($handle), "\r\n") !== false) {
			$linebreak = "\r\n";
		} else {
			$linebreak = "\n";
		}
		} else {
			trigger_error("Unable to open file ($idlist) for reading", E_USER_ERROR);
		}
		fclose($handle);
	$handle = @fopen($idlist, 'rt');
	if ($handle) {
		while (($line = fgets($handle)) !== false) {
			if (strpos($line, $id . $linebreak) !== false) {
				$banned = true;
				break;
			}
		}
	} else {
		trigger_error("Unable to open file ($idlist) for reading", E_USER_ERROR);
	}
	fclose($handle);
}

if ($banned == true) {
	echo _BAN;
} else {
	echo _OK;
}
exit;
?>