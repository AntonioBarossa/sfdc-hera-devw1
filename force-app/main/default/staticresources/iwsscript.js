var softphone_connector_initialized = false;
function networkError(message) {
    log.error(message);
}
function onIdentity(message) {
}
function onConnectedSession(message) {
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateOpenCtiStatus(false);
    sfutil.updateConnectionLed("led-yellow", "Connection in standby ...");
}
function onDisconnectedSession(message) {
    $("#led").removeClass();
    $("#led").addClass("led-red");
    $(".led-msg p").text("Session disconnected");
    sfutil.updateOpenCtiStatus(false);
    softphone_connector_initialized = false;
}
function onActivateSession(message) {
    logsf.info("onActivateSession ", message);
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateConnectionLed("led-green", "Connection estabilished");
    sfutil.updateOpenCtiStatus(true);
    sfutil.enableClickToDial();
    sfutil.addTabFocusListener();
    softphone_connector_initialized = true;
}
function onPostActivateSession(message) {
}
function onDeactivateSession(message) {
}
function onChannelStatus(message) {
    logsf.info("onChannelStatus : ", message);
}
function onEventAgentNotReady(message) {
    logsf.info("onEventAgentNotReady : ", message);
}
function onEventAgentNotReadyAfterCallWork(message) {
}
function onEventAgentReady(message) {
    logsf.info("onEventAgentReady : ", message);
}
function onEventAgentLogout(message) {
}
function onEventAgentLogin(message) {
}
function onEventRingingInbound(message) {
    var callback = function (response) {
        if (response.success) {
            logsf.info('API method call executed successfully! returnValue:', response.returnValue);
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    if (iwscore.getLayoutParams().integrationType === 'wwe' || iwscore.getLayoutParams().integrationType === 'pure-embeddable') {
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
function onEventRingingInternal(message) {
}
function onEventRingingConsult(message) {
}
function onEventRingingOutbound(message) {
}
function onEventEstablishedInbound(message) {
    logsf.info("onEventEstablishedInbound , message : ", message);
    sfutil.createTask(message, 'Phone', message.ANI.replace("tel:", ""), message.MediaType + " - " + message.ConnectionID || message.callId);
}
function onEventPartyChangedInbound(message) {
}
function onEventPartyChangedOutbound(message) {
}
function onEventEstablishedInternal(message) {
}
function onEventEstablishedConsult(message) {
}
function onEventEstablishedOutbound(message) {
}
function onEventHeldInbound(message) {
}
function onEventHeldInternal(message) {
}
function onEventHeldConsult(message) {
}
function onEventHeldOutbound(message) {
}
function onEventRetrievedInbound(message) {
}
function onEventRetrievedInternal(message) {
}
function onEventRetrievedConsult(message) {
}
function onEventRetrievedOutbound(message) {
}
function onEventAttachedDataChangedInbound(message) {
}
function onEventAttachedDataChangedInternal(message) {
}
function onEventAttachedDataChangedConsult(message) {
}
function onEventAttachedDataChangedOutbound(message) {
}
function onEventReleasedInbound(message) {
}
function onEventReleasedInternal(message) {
}
function onEventReleasedConsult(message) {
}
function onEventReleasedOutbound(message) {
}
function onEventDialingInternal(message) {
}
function onEventDialingConsult(message) {
}
function onEventDialingOutbound(message) {
}
function onChatEventRingingInbound(message) {
    var callback = function (response) {
        if (response.success) {
            logsf.info('API method call executed successfully! returnValue:', response.returnValue);
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    var isVisibleCallback = function (response) {
        if (response.success) {
            if (!response.returnValue.visible) {
                sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
            }
            else {
                logsf.info('Softphone Panel is open: ', response.returnValue.visible);
            }
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    if (iwscore.getLayoutParams().integrationType === 'wwe' || iwscore.getLayoutParams().integrationType === 'pure-embeddable') {
        sforce.opencti.isSoftphonePanelVisible({ callback: isVisibleCallback });
    }
}
function onChatEventRingingConsult(message) {
}
function onChatEventEstablishedInbound(message) {
    logsf.info("onChatEventEstablishedInbound , message : ", message);
    let email = message.Service == "PureCloud" ? message.attachdata["context.email"] : message.attachdata.EmailAddress;
    sfutil.createTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onChatEventEstablishedConsult(message) {
}
function onChatEventReleasedInbound(message) {
}
function onChatEventReleasedConsult(message) {
}
function onChatEventMarkDoneInbound(message) {
    logsf.info("onChatEventMarkDoneInbound , message : ", message);
}
function onChatEventTranscriptLink(message) {
}
function onChatEventPartyRemovedInbound(message) {
}
function onChatEventPartyAddedInbound(message) {
}
function onChatEventPartyChangedInbound(message) {
}
function onEmailEventRingingInbound(message) {
}
function onEmailEventEstablishedInbound(message) {
    logsf.info("onEmailEventEstablishedInbound , message : ", message);
    let email = message.Service == "PureCloud" ? message.EmailAddress : message.attachdata.EmailAddress;
    sfutil.createTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onEmailEventReleasedInbound(message) {
}
function onEmailEventReplyEstablishedOutbound(message) {
}
function onEmailEventReplyReleased(message) {
}
function onEmailEventReplyCancelled(message) {
}
function onEmailEventSessionInfo(message) {
}
function onDelegateCommand(message) {
}
function onRegisterCommand(message) {
}
function onInhibitCommand(message) {
}
function onWdeSwitchInteraction(message) {
    logsf.info("Called onWdeSwitchInteraction: ", message);
    let id = message.ConnectionID || message.InteractionID;
    if (!id) {
        logsf.info("interaction id null... returning");
        return;
    }
    var event = iwscore.mapInteractions[id.toLowerCase()];
    if (event) {
        sfutil.manageSwitchInteraction(event);
    }
}
function onSwitchInteractionInbound(message) {
    log.debug("Called onSwitchInteractionInbound ");
    onSwitchInteraction(message);
}
function onSwitchInteractionPEF(message) {
    log.debug("Called onSwitchInteractionInbound ");
    logsf.info("Called onSwitchInteractionInbound: ", message);
    onWdeSwitchInteraction(message);
}
function onSwitchInteraction(message) {
    log.debug("Called onWdeSwitchInteraction: " + message);
    sfutil.checkExists(message);
}
function onWorkitemEventEstablishedInbound(message) {
    log.debug("Called onWorkitemEventEstablishedInbound: ");
    logsf.info(message);
}
function onWorkitemEventMarkDoneInbound(message) {
    logsf.info("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventRingingInbound(message) {
    log.debug("Called onWorkitemEventRingingInbound: ");
}
function onEventMarkDoneOutbound(message) {
}
