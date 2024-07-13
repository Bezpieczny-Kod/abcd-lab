const HttpSender = Java.type('org.parosproxy.paros.network.HttpSender');
const System = Java.type('java.lang.System')
const ScriptVars = Java.type('org.zaproxy.zap.extension.script.ScriptVars');

function sendingRequest(msg, initiator, helper) {
  if (initiator !== HttpSender.AUTHENTICATION_INITIATOR && msg.isInScope()) {
    /*
        If you want pass var between scripts in ZAP automation framework use:
        ScriptVars.setGlobalVar("foo", "token")
        ScriptVars.getGlobalVar("token")

        https://www.javadoc.io/doc/org.zaproxy/zap/2.5.0/org/zaproxy/zap/extension/script/ScriptVars.html
    */
    const token = System.getenv("AUTH_TOKEN");

    if (token) {
        msg.getRequestHeader().setHeader("Authorization", "Bearer " + token);
    }
  }
}

function responseReceived(msg, initiator, helper) {}