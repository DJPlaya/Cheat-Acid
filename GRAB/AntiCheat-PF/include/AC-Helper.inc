#include <smjansson>
#include <discord/stocks>

enum {
	T_LOW,
	T_MED,
	T_HIGH,
	T_DEF,
	T_TEST
};

/**
 * Pre hook for detections
 *
 * @param client        Client entity index.
 * @param level         Trigger level, see enum.
 * @param cheatDesc     Short name of the detected cheat.
 * @return              Plugin_Continue to do nothing.
 *                      Plugin_Changed to modify various values.
 *                      Plugin_Handled to not call post hook AC_Trigger.
 *                      Plugin_Stop to ignore trigger fully.
 */
//forward Action AC_Triggered(int client, int &level, char[] cheatDesc);

/**
 * Post hook for detections
 *
 * @param client        Client entity index.
 * @param level         Trigger level, see enum.
 * @param cheatDesc     Short name of the detected cheat.
 * @param cheatInfo     The stats that were detected and assumed cheated.
 * @noreturn
 */
native void AC_Trigger(int client, int level, char[] cheatDesc);

/**
 * Prints a message to admins in chat and console, plays short beep sound.
 *
 * @param format        Formatting things.
 * @param any           Variable number of format parameters.
 * @noreturn
 */
native void AC_NotifyAdmins(const char[] format, any ...);

/**
 * Notify discord webhook
 *
 * @param client        Client entity index.
 * @param level         Trigger level, see enum.
 * @param cheatDesc     Short name of the detected cheat.
 * @param cheatInfo     The stats that were detected and assumed cheated.
 * @noreturn
 */
native void AC_NotifyDiscord(int client, int level, char[] cheatDesc, char[] cheatInfo);

/**
 * Logs detections to specified log file.
 *
 * @param format        Formatting things.
 * @param any           Variable number of format parameters.
 * @noreturn
 */
native void AC_LogToServer(const char[] format, any ...);

/**
 * Enable to not get punished due to detections, everything works as normal besides punishments.
 *
 * @param client        Client entity index.
 * @return              True if no punishments.
 */
native bool AC_IsTesting(int client);

/**
 * Built to not false pos on bad players (tends to happen without this)
 *
 * @param client        Client entity index.
 * @param bestLJ        Short name of best LJ ex. Green, Red, Gold.
 * @return              True if their pb is high enough.
 */
native bool AC_AllowDetect(int client);

/**
 * Check to not false pos while in various states.
 *
 * @param client				Client entity index.
 * @param watrer				Check for water level?
 * @return 						  True if the test passed.
 */
stock bool IsMoveTypeLeagl(int client, bool water = true) {
	MoveType iMoveType = GetEntityMoveType(client);

	return(!water || GetEntProp(client, Prop_Data, "m_nWaterLevel") < 2) &&
				(GetEntityFlags(client) & FL_ATCONTROLS) == 0 &&
				(iMoveType == MOVETYPE_WALK || iMoveType == MOVETYPE_ISOMETRIC || iMoveType == MOVETYPE_LADDER);
}
/////////////////////////////////////////////////////
///////////////// DISCORD API////////////////////////
/////////////////////////////////////////////////////
methodmap MessageEmbed < Handle {
	public MessageEmbed() {
		Handle hObj = json_object();
		return view_as<MessageEmbed>(hObj);
	}

	public bool GetColor(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "color", buffer, maxlength);
	}

	public void SetColor(const char[] color) {
		json_object_set_new(this, "color", json_string(color));
	}

	public bool GetTitle(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "title", buffer, maxlength);
	}

	public void SetTitle(const char[] title) {
		json_object_set_new(this, "title", json_string(title));
	}

	public bool GetTitleLink(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "title_link", buffer, maxlength);
	}

	public void SetTitleLink(const char[] title_link) {
		json_object_set_new(this, "title_link", json_string(title_link));
	}

	public bool GetImage(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "image_url", buffer, maxlength);
	}

	public void SetImage(const char[] image_url) {
		json_object_set_new(this, "image_url", json_string(image_url));
	}

	public bool GetAuthor(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "author_name", buffer, maxlength);
	}

	public void SetAuthor(const char[] author_name) {
		json_object_set_new(this, "author_name", json_string(author_name));
	}

	public bool GetAuthorLink(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "author_link", buffer, maxlength);
	}

	public void SetAuthorLink(const char[] author_link) {
		json_object_set_new(this, "author_link", json_string(author_link));
	}

	public bool GetAuthorIcon(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "author_icon", buffer, maxlength);
	}

	public void SetAuthorIcon(const char[] author_icon) {
		json_object_set_new(this, "author_icon", json_string(author_icon));
	}

	public bool GetThumb(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "thumb_url", buffer, maxlength);
	}

	public void SetThumb(const char[] thumb_url) {
		json_object_set_new(this, "thumb_url", json_string(thumb_url));
	}

	public bool GetFooter(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "footer", buffer, maxlength);
	}

	public void SetFooter(const char[] footer) {
		json_object_set_new(this, "footer", json_string(footer));
	}

	public bool GetFooterIcon(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "footer_icon", buffer, maxlength);
	}

	public void SetFooterIcon(const char[] footer_icon) {
		json_object_set_new(this, "footer_icon", json_string(footer_icon));
	}
	/**
	 * Note: Setting Fields will delete the handle!
	 */
	property Handle Fields {
		public get() {
			return json_object_get(this, "fields");
		}

		public set(Handle value) {
			json_object_set_new(this, "fields", value);
		}
	}

	public void AddField(const char[] name, const char[] value, bool inline) {
		Handle hObj = json_object();
		json_object_set_new(hObj, "name", json_string(name));
		json_object_set_new(hObj, "value", json_string(value));
		json_object_set_new(hObj, "inline", json_boolean(inline));
		Handle hArray = this.Fields;
		if(this.Fields == null) {
			hArray = json_array();
		}
		json_array_append_new(hArray, hObj);
		this.Fields = hArray;
	}

	//Below don't support Slack Mode
	public bool GetDescription(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "description", buffer, maxlength);
	}

	public void SetDescription(const char[] description) {
		json_object_set_new(this, "description", json_string(description));
	}

	public bool GetURL(char[] buffer, int maxlength) {
		return JsonObjectGetString(this, "url", buffer, maxlength);
	}

	public void SetURL(const char[] url) {
		json_object_set_new(this, "url", json_string(url));
	}
};

methodmap DiscordWebHook < Handle {
	public DiscordWebHook(char[] url) {
		Handle mp = json_object();
		json_object_set_new(mp, "__url", json_string(url));
		Handle data = json_object();
		json_object_set_new(mp, "__data", data);

		return view_as<DiscordWebHook>(mp);
	}

	public void GetUrl(char[] buffer, int maxlength) {
		JsonObjectGetString(this, "__url", buffer, maxlength);
	}

	property bool SlackMode {
		public get() {
			return JsonObjectGetBool(this, "__slack", false);
		}

		public set(bool value) {
			json_object_set_new(this, "__slack", (value) ? json_true() : json_false());
		}
	}

	property Handle Data {
		public get() {
			return json_object_get(this, "__data");
		}

		public set(Handle value) {
			json_object_set_new(this, "__data", value);
		}
	}

	public void UpdateDataObject(char[] key, Handle hObject) {
		Handle data = this.Data;
		json_object_set_new(data, key, hObject);
		delete data;
	}

	public bool GetDataBool(char[] key, bool defaultValue=false) {
		Handle data = this.Data;
		bool value = JsonObjectGetBool(data, key, defaultValue);
		delete data;
		return value;
	}

	public bool GetDataString(char[] key, char[] buffer, int maxlength) {
		Handle data = this.Data;
		bool success = JsonObjectGetString(data, key, buffer, maxlength);
		delete data;
		return success;
	}

	public void Embed(MessageEmbed hObj) {
		Handle data = this.Data;
		Handle hArray = json_object_get(data, "embeds");

		if(hArray == null) {
			hArray = json_array();
			json_object_set(data, "embeds", hArray);
		}

		json_array_append_new(hArray, hObj);
		delete hArray;
		delete data;

	}

	property bool tts {
		public get() {
			return this.GetDataBool("tts", false);
		}

		public set(bool value) {
			this.UpdateDataObject("tts", json_boolean(value));
		}
	}

	public bool GetUsername(char[] buffer, int maxlength) {
		return this.GetDataString("username", buffer, maxlength);
	}

	public void SetUsername(const char[] name) {
		this.UpdateDataObject("username", json_string(name));
	}

	public bool GetAvatar(char[] buffer, int maxlength) {
		return this.GetDataString("icon_url", buffer, maxlength);
	}

	public void SetAvatar(const char[] icon_url) {
		this.UpdateDataObject("icon_url", json_string(icon_url));
	}

	public bool GetContent(char[] buffer, int maxlength) {
		return this.GetDataString("content", buffer, maxlength);
	}

	public void SetContent(const char[] content) {
		this.UpdateDataObject("content", json_string(content));
	}

	public native void Send();
};
/////////////////////////////////////////////////////
////////////// END DISCORD API///////////////////////
/////////////////////////////////////////////////////

// handles most the natives
public SharedPlugin __pl_ac = {
	name = "AC-Main",
	file = "AC-Main.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_ac_SetNTVOptional() {
	MarkNativeAsOptional("AC_Trigger");
	MarkNativeAsOptional("AC_NotifyAdmins");
	MarkNativeAsOptional("AC_NotifyDiscord");
	MarkNativeAsOptional("AC_LogToServer");
	MarkNativeAsOptional("AC_IsTesting");
}
#endif

// handles if someone can get detected for mouse movements and strafe stats
public SharedPlugin __pl_js = {
	name = "JS-Module",
	file = "JumpStats.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_js_SetNTVOptional() {
	MarkNativeAsOptional("AC_AllowDetect");
}
#endif
