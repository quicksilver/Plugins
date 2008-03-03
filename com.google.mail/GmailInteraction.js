var Gmail = new Object();

// The base URL to open.
// TODO (bonneau): Internationalize URL.
Gmail.gmailUrl = "http://mail.google.com/mail";

// The feed URL.
Gmail.feedUrl = "/feed/atom";

// The inbox URL;
Gmail.inboxUrl = "/?search=inbox&source=macgmailwidget&client=google-macgmailwidget&auth="

// The search URL.
Gmail.searchUrl = "/?search=query&view=tl&start=0&init=1&fs=1&source=macgmailwidget&client=google-macgmailwidget&q=";

// The message URL.
Gmail.messageUrl = "/?fs=1&tf=1&source=macgmailwidget&client=google-macgmailwidget&view=cv&search=all&th=";

// The compose URL.
Gmail.composeUrl = "/?view=cm&tf=0&source=macgmailwidget&client=google-macgmailwidget&auth=";

// The "Forgot password?" URL.
Gmail.forgotPasswordUrl = "https://www.google.com/accounts/ForgotPasswd";

// The authentication URL.
Gmail.authUrl = 'https://www.google.com/accounts/ClientAuth';

// The token URL.
Gmail.tokenUrl = 'https://www.google.com/accounts/IssueAuthToken';

// The auth token, used for auth + forward in links.
Gmail.auth;

// Try to authenticate the user.
Gmail.authenticate = function(callback) {
  var request = new XMLHttpRequest();
  request.onload = function(e) {callback(e, request);}
  request.overrideMimeType("text/plain");
  request.open("POST", Gmail.authUrl);
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  request.setRequestHeader("Cache-Control", "no-cache");

  var account = Prefs.getAccount();
  var password = Prefs.getPassword(account);

  var params = "Email=" + encodeURI(account) + "&Passwd=" + encodeURI(password)
      + "&source=macgmailwidget";

  request.send(params);
}

// Sends off a request to issue an auth token based on the given SID and
// LSID values.  This auth token will be used in the URLs for searching and
// linking to the inbox or to a given label.
Gmail.getAuthToken = function(sid, lsid, callback) {
  var request = new XMLHttpRequest();

  request.onload
      = function(e) {Gmail.getAuthTokenCallback(e, request, callback);}
  request.overrideMimeType("text/xml");
  request.open("POST", Gmail.tokenUrl);
  request.setRequestHeader("Cache-Control", "no-cache");

  var params = sid + "&" + lsid + "&service=mail";
  request.send(params);
}

// Callback for the "issue auth token" request.  The response text
// should be the the auth token.
Gmail.getAuthTokenCallback = function(e, request, callback) {
  Gmail.auth = request.responseText;
  callback();
}

// Gets the URL to use for this widget instance, taking into account if the
// widget is configured for a label or for the inbox.
Gmail.getFeedUrl = function() {
  var label = Prefs.getLabel();
  var url;
  if (label != null) {
    url = Gmail.gmailUrl + Gmail.feedUrl + "/" + Widget.stripLabel(label);
  } else {
    url = Gmail.gmailUrl + Gmail.feedUrl;
  }

  url += "/?auth=" + Gmail.auth + "&client=google-macgmailwidget";
  return url;
}

// Gets the URL for auth + forward to the user's Gmail inbox.
Gmail.getInboxUrl = function() {
  var url = Gmail.gmailUrl + Gmail.inboxUrl + Gmail.auth;
  return url;
}

// Gets the URL to ask Gmail to execute the given search query.
Gmail.getSearchUrl = function(search) {
  var url = Gmail.gmailUrl + Gmail.searchUrl + search + "&auth=" + Gmail.auth;
  return url;
}

// Gets the URL to the specific message with the given message ID.
Gmail.getMessageUrl = function(messageId) {
  var url = Gmail.gmailUrl + Gmail.messageUrl + messageId + "&auth="
      + Gmail.auth;
  return url;
}

// Gets the URL to compose a message.
Gmail.getComposeUrl = function() {
  var url = Gmail.gmailUrl + Gmail.composeUrl + Gmail.auth;
  return url;
}
