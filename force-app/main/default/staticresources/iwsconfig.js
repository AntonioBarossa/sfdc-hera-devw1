log.setLogLevel(enumloglevel.error);
if (softphoneSettings.GEN_LOG_LEVEL == 'Debug') {
    log.setLogLevel(enumloglevel.debug);
}
switch (softphoneSettings.GEN_INTEGRATION_TYPE) {
    case "PURECLOUD":
        loadPureRequestConfig();
        break;
    case "WDE":
        loadWDE();
        break;
    case "WWE":
        loadWWE();
        break;
}
var GC_ENVIRONMENT = softphoneSettings.PEF_GC_ENVIRONMENT;

function loadWDE() {
    iwscore.getLayoutParams().integrationType = "wde";
    iwscore.createConnection(softphoneSettings.WDE_HOST, softphoneSettings.WDE_PORT, { 'protocol': softphoneSettings.WDE_PROTOCOL });
    addFilters();
}

function addFilters() {
    addFilter("onEventRingingInbound", "action");
    addFilter("onEventEstablishedInbound", "action");
    addFilter("onEventMarkDoneInbound", "action");
    addFilter("onEventDialingOutbound", "action");
    addFilter("onEventDialingInternal", "action");
    addFilter("onEventRingingInternal", "action");
    addFilter("onEventEstablishedOutbound", "action");
    addFilter("onEventMarkDoneOutbound", "action");
    addFilter("onEventDialingConsult", "action");
    addFilter("onEventRingingConsult", "action");
    addFilter("onEventEstablishedConsult", "action");
    addFilter("onEventMarkDoneConsult", "action");
    addFilter("onEventPartyChangedInbound", "action");
    
    addFilter("onEventRingingOutbound", "action");
    addFilter("onChatEventRingingInbound", "action");
    addFilter("onChatEventRingingConsult", "action");
    addFilter("onEmailEventRingingInbound", "action");
    addFilter("onWorkitemEventRingingInbound", "action");
    addFilter("onWorkitemEventRingingInbound", "action");
    console.log('### iwsconfig.addFilters() | FILTERS LOADED!');
}

function action(message)
{
    log.debug("Called action function...");
    //if the attach is defined
    if(message.attachdata.CRM) {
        log.debugFormat("action - message.attachdata.CRM [{0}] ", message.attachdata.CRM);
        return (message.attachdata.CRM == "sfdc");
    } else {
        
        return true;
    }
}

function loadPureRequestConfig() {
    var auth = {
        environment: softphoneSettings.PEF_GC_ENVIRONMENT,
        notReadyPresenceId: softphoneSettings.PEF_NOT_READY_ID,
        onQueuePresenceId: softphoneSettings.PEF_ON_QUEUE_ID
    };
    var params = {
        settings: {
            sso: false,
            embedWebRTCByDefault: softphoneSettings.PEF_EMBED_WEB_RTC_BY_DEFAULT == "true",
            hideWebRTCPopUpOption: softphoneSettings.PEF_HIDE_WEB_RTC_POP_UP_OPTION == "true",
            enableCallLogs: softphoneSettings.PEF_ENABLE_CALL_LOGS == "true",
            hideCallLogSubject: softphoneSettings.PEF_HIDE_CALL_LOG_SUBJECT == "true",
            hideCallLogContact: softphoneSettings.PEF_HIDE_CALL_LOG_CONTACT == "true",
            hideCallLogRelation: softphoneSettings.PEF_HIDE_CALL_LOG_RELATION == "true",
            enableTransferContext: softphoneSettings.PEF_ENABLE_TRANSFER_CONTEXT == "true",
            dedicatedLoginWindow: softphoneSettings.PEF_DEDICATED_LOGIN_WINDOW == "true",
            embeddedInteractionWindow: softphoneSettings.PEF_EMBEDDED_INTERACTION_WINDOW == "true",
            enableConfigurableCallerId: softphoneSettings.PEF_ENABLE_CONFIGURABLE_CALLER_ID == "true",
            enableServerSideLogging: softphoneSettings.PEF_ENABLE_SERVER_SIDE_LOGGING = "true",
            enableCallHistory: softphoneSettings.PEF_ENABLE_CALL_HISTORY == "true",
            theme: {
                primary: "#HHH",
                text: "#FFF"
            }
        },
        clientIds: {
            "mypurecloud.com": "5b334989-e1b0-4a37-85f7-237151c91278",
            "mypurecloud.de": "2850f585-583d-4c3d-8dfc-2ff77aa41c11",
            "mypurecloud.ie": "58905000-8cd7-4909-b939-97c4e6a03581",
            "mypurecloud.jp": "02e69958-dea2-448a-81ab-bcbebe07fd72",
            "mypurecloud.com.au": "238d8aa6-cddf-4945-aa30-9a7acb2cc603",
            "usw2.pure.cloud": "eaabe512-ef46-4ab8-ad74-f6c111dcd871"
        },
        helpLinks: {}
    };
    logsf.info("params : ", params);
    var url = `https://apps.${softphoneSettings.PEF_GC_ENVIRONMENT}/crm/softphoneGenericCRM/index.html?request_configuration=true&crm_domain=${window.location.origin}`;
    logsf.info("url : ", url);
    var config = {
        context: window,
        layoutType: "frame",
        integrationType: "pure-embeddable",
        url: url,
        auth: auth,
        pefParams: params
    };
    iwscore.initCTI(config);
    iwscore.enableCTI();
}
function loadPure() {
    var auth = {
        environment: softphoneSettings.PEF_GC_ENVIRONMENT,
        notReadyPresenceId: softphoneSettings.PEF_NOT_READY_ID,
        onQueuePresenceId: softphoneSettings.PEF_ON_QUEUE_ID
    };
    var params = "?crm_domain=" + window.location.origin;
    params += "&dedicatedLoginWindow=" + softphoneSettings.PEF_DEDICATED_LOGIN_WINDOW;
    params += "&enableCallLogs=" + softphoneSettings.PEF_ENABLE_CALL_LOGS;
    params += "&hideCallLogContact=" + softphoneSettings.PEF_HIDE_CALL_LOG_CONTACT;
    params += "&hideCallLogRelation=" + softphoneSettings.PEF_HIDE_CALL_LOG_RELATION;
    params += "&hideCallLogSubject=" + softphoneSettings.PEF_HIDE_CALL_LOG_SUBJECT;
    params += "&hideWebRTCPopUpOption=" + softphoneSettings.PEF_HIDE_WEB_RTC_POP_UP_OPTION;
    params += "&embedWebRTCByDefault=" + softphoneSettings.PEF_EMBED_WEB_RTC_BY_DEFAULT;
    logsf.info("params : ", params);
    iwscore.initCTI({
        context: window,
        layoutType: "frame",
        integrationType: "pure-embeddable",
        url: "https://apps.mypurecloud.com/crm/softphoneGenericCRM/index.html" + params,
        auth: auth
    });
    iwscore.enableCTI();
}
function loadWWE() {
    iwscore.initCTI({
        context: window,
        integrationType: "wwe",
        layoutType: "frame",
        url: softphoneSettings.wweUrl
    });
    iwscore.enableCTI();
}