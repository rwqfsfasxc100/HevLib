extends Node

class _SteamWebApi:
	var scripts = [
		
	]
	var accessToken : String
	var umqid : String
	var steamid : String
	var message : int = 0
	
	enum LoginStatus {LoginFailed,LoginSuccessful,SteamGuard}
	enum UserStatus {Offline = 0,Online = 1,Busy = 2,Away = 3,Snooze = 4}
	enum ProfileVisibility {Private = 1,Public = 3,FriendsOnly = 8}
	enum AvatarSize {Small,Medium,Large}
	enum UpdateType {UserUpdate,Message,Emote,TypingNotification}
	
	const Friend = {
		steamid = "",
		blocked = false,
		friendSince = 0,
	}
	
	const User = {
		steamid = "",
		profileVisibility = ProfileVisibility.Public,
		profileState = 0,
		nickname = "",
		lastLogoff = 0,
		profileUrl = "",
		avatarUrl = "",
		status = UserStatus.Offline,
		realName = "",
		primaryGroupId = "",
		joinDate = "",
		locationCountryCode = "",
		locationStateCode = "",
		locationCityId = 0,
	}
	
	const Group = {
		steamid = "",
		inviteonly = false
	}
	
	const GroupInfo = {
		steamid = "",
		creationDate = 0,
		"name":"",
		headline = "",
		summary = "",
		abbreviation = "",
		profileUrl = "",
		avatarUrl = "",
		locationCountryCode = "",
		locationStateCode = "",
		locationCityId = 0,
		favoriteAppId = 0,
		members = 0,
		usersOnline = 0,
		usersInChat = 0,
		usersInGame = 0,
		"owner":"",
	}
	
	const Update = {
		timestamp = 0,
		origin = "",
		localMessage = false,
		type = UpdateType.UserUpdate,
		message = "",
		status = UserStatus.Offline,
		nick = ""
	}
	
	const ServerInfo = {
		serverTime = 0,
		serverTimeString = ""
	}
	
	func Authenticate(username: String, password: String, emailauthcode : String = "") -> int:
		var response : String = steamRequest("ISteamOAuth2/GetTokenWithCredentials/v0001","client_id=DE45CD61&grant_type=password&username=" + username.http_escape() + "&password=" + password.http_escape() + "&x_emailauthcode=" + emailauthcode + "&scope=read_profile%20write_profile%20read_client%20write_client")
		if (response != null):
			var data = JSON.parse(response)
			if (data["access_token"] != null):
				var accessToken = data["access_token"]
				var out = login()
				if out == LoginStatus.LoginSuccessful:
					return out
				else: return LoginStatus.LoginFailed
			elif data["x_errorcode"] == "steamguard_code_required":
				return LoginStatus.SteamGuard;
			else:
				return LoginStatus.LoginFailed;
		else:
			return LoginStatus.LoginFailed
	
	func login() -> bool:
		var response = steamRequest("ISteamWebUserPresenceOAuth/Logon/v0001","?access_token=" + accessToken)

		if (response != null):
			var data = JSON.parse(response);
			if (data["umqid"] != null):
				steamid = data["steamid"];
				umqid = data["umqid"];
				message  = data["message"];
				return true;
			else:
				return false
		else:
			return false
	
	func steamRequest(get : String, post : String) -> String:
#			System.Net.ServicePointManager.Expect100Continue = false;
			var request = HTTPClient.new()
#			var request : HTTPRequest = WebRequest.Create("https://api.steampowered.com/" + get);
#			request.Host = "api.steampowered.com:443";
#			request.ProtocolVersion = HttpVersion.Version11;
#			request.Accept = "*/*";
#			
			
			var headers = PoolStringArray([
				"Accept-Encoding: gzip, deflate",
				"Accept-Language: en-us",
				"User-Agent: Steam 1291812 / iPhone",
				"Accept: */*"
				])
			
			
			if (post != ""):
				request.Method = "POST";
				postBytes = Encoding.ASCII.GetBytes(post);
				request.ContentType = "application/x-www-form-urlencoded";
				request.ContentLength = postBytes.Length;

				requestStream = request.GetRequestStream();
				requestStream.Write(postBytes, 0, postBytes.Length);
				requestStream.Close();

				message += 1
#			else:
			var response = request.GetResponse();
			if (response.StatusCode != 200): return null;

			var src = StreamReader(response.GetResponseStream()).ReadToEnd()
			response.close();
			return src;
			
	
