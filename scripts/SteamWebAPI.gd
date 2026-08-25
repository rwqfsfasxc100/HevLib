# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

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
			
	
