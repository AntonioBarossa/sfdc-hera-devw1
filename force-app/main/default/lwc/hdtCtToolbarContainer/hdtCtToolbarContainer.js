import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import { loadScript } from 'lightning/platformResourceLoader';
import id from '@salesforce/user/Id';
import OBJECT_NAME from '@salesforce/schema/CampaignMember';
import postSlotRequest from '@salesforce/apex/HDT_LC_RecallMe.postSlotRequest';
import postAppointment from '@salesforce/apex/HDT_LC_RecallMe.postAppointment';
import saveEcid from '@salesforce/apex/HDT_LC_CtToolbar.updateCampaignMember';
import updateCampaignMemberStatus from '@salesforce/apex/HDT_LC_CtToolbar.updateCampaignMemberStatus';
import getStatus from '@salesforce/apex/HDT_LC_CtToolbar.getStatusByEcid';
import createActivity from '@salesforce/apex/HDT_LC_CtToolbar.createActivity';
import updateActivity from '@salesforce/apex/HDT_LC_CtToolbar.updateActivity';
import saveEcidInSales from '@salesforce/apex/HDT_LC_CtToolbar.saveEcidInSales';
import createActivityInbound from '@salesforce/apex/HDT_LC_CtToolbar.createActivityInbound';
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';    // params: n/a

export default class HdtCtToolbarContainer extends NavigationMixin(LightningElement) {
    showPanel = false;
    numberToCall = '';
    @api objectApiName;
    @track showRecallMe = false;
    @track showModal = false;
    @track toolbarAttributes = [];
    uuid;
    saveScriptDone;
    @api agentidc;
    @api isHide = false;
    @api ecid = '';
    @api campaignMemberId;
    @track selectedTimeSlot = [];
    @track dataList = [];
    columnsList = [
        { label: 'StartDate', fieldName: 'StartDate', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' } },
        { label: 'EndDate', fieldName: 'EndDate', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' } },
    ];
    @track activityId;
    @track startCallDateTime;
    @track endCallDateTime;
    @track waitingTime;
    @track callDuration;
    @api regLink = 'https://herapresfdc.cloudando.com/ctreplay/externalView/search?filter={"filter":{"ecid":""},"sort":{"startTs":-1},"index":0}';
    @api regLinkHost = 'https://herapresfdc.cloudando.com/ctreplay/externalView/search?';
    @api regListParam = 'filter={"filter":{"ecid":"[PLACE]"},"sort":{"startTs":-1},"index":0}';
    @track registrationLinkVo;
    @track saleId;

    iconName = '';
    agentStatus = '';
    spinner = true;
    dialing = false;
    title = 'Scheda cliente';

    connectedCallback() {
        console.log('# connectedCallback #');
        this.iconName = 'utility:log_a_call';
        this.agentStatus = 'standard:employee_contact';

        window.addEventListener('toolbarCallBack', this.contactCallback);

        Promise.all([
            loadScript(this, cttoolbar)
        ]).then(() => console.log('# javascript Loaded #'))
            .catch(error => console.log('promise error: ' + error));


        /* setTimeout(() => {
             this.enableCallback();
             this.spinner = false;           
         }, 1000);*/

        //get saleId if in wizard-vendita page
        if (location.href.indexOf('wizard-vendita') > 0) {
            let currentUrl = new URL(location.href);
            this.saleId = currentUrl.searchParams.get('c__saleId');
        }
    }

    closeModal() {
        this.saveScript("Appuntamento telefonico personale", true);
        // window.TOOLBAR.EASYCIM.saveScript(this.uuid, "Appuntamento telefonico personale", true);
        // window.TOOLBAR.EASYCIM.saveScript('68-60f69967@pddialer1.saashra.priv', "Appuntamento telefonico personale", true);
        // window.open("/s/campaignmember/" + this.campaignMemberId, "_self");
        /* this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: this.campaignMemberId,
              objectApiName: OBJECT_NAME.objectApiName,
              actionName: 'view'
          },*/
        // });
        console.log('****AFTERSENDSAVE');
    }

    toolbarEvent(event) {
        console.log('>>> toolbarEvent');
        console.log('********** EVENT TYPE > ' + event.detail.eventType);
        console.log('>>> EVENT OBJ > ' + JSON.stringify(event.detail.eventObj));

        let eventType = event.detail.eventType;
        eventType = eventType.toUpperCase();
        let callData = [];
        let ecid = '';
        let checkMemberId = false;
        let count = 0;
        console.log("######:" + eventType)
        switch (eventType) {
            case 'CONNECTIONCLEARED':
                console.log("*****DentroConnection");
                this.toolbarAttributes = event.detail.eventObj;
                if(this.toolbarAttributes.id) {
                    this.uuid = this.toolbarAttributes.id;
                }
                if (this.toolbarAttributes.type != null && this.toolbarAttributes.type != undefined && this.toolbarAttributes.type == 'inbound') {
                    this.saveScript('Positivo', true);
                } else {
                    callData = event.detail.CallData;
                    this.endCallDateTime = this.toolbarAttributes.endTime;
                    this.callDuration = this.toolbarAttributes.time_duration_sec != null ? (parseInt(this.toolbarAttributes.time_duration_sec) / 60).toFixed(2) : 0; // convert in minutes
                    this.waitingTime = this.toolbarAttributes.waitingTime != null ? (parseInt(this.toolbarAttributes.waitingTime) / 60).toFixed(2) : 0; // convert in minutes
                    let ecid2 = window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                    this.ecid = ecid2;
                    console.log('*********ConnectionCleared:2' + ecid2);
                    this.sendStatus(ecid2);
                    if (this.activityId != null) {
                        this.trackActivity('updatectivity');
                    }

                    updateActivity({
                        ecid: ecid2,
                        endCall: this.endCallDateTime,
                        callDuration: this.callDuration,
                        waitingTime: this.waitingTime
                    }).then(data => {
                        console.log('updateActivity --- ' + JSON.stringify(data));
                    }).catch(err => {
                        console.log(JSON.stringify(err));
                    });
                    console.log('*********ConnectionCleared:');
                }
                if(this.saveScriptDone) {
                    console.log('BEFORE OFFLINEEND');
                    if(this.uuid) {
                        console.log('WITH UUID');
                        window.TOOLBAR.CONTACT.OfflineEnd(this.uuid);
                    } else {
                        console.log('WITHOUT UUID');
                        getCachedUuid()
                        .then(cachedUuid => {
                            console.log('WITHOUT UUID RETRIEVED : ' + cachedUuid);
                            window.TOOLBAR.CONTACT.OfflineEnd(cachedUuid)
                        });
                    }
                }
                this.saveScriptDone = false;
                break;
            case 'POPUP':
                //if (count == 0) {
                console.log('*******INSIDEPOPUP');
                this.toolbarAttributes = event.detail.eventObj;
                
                // if(this.toolbarAttributes.id) {
                    this.uuid = this.toolbarAttributes.id;
                // }
                callData = event.detail.CallData;
                //get ecid value from callData
                console.log('******preIF Inbound');
                if(this.toolbarAttributes != null && this.toolbarAttributes.type == 'inbound'){
                    console.log('******postIF Inbound2');
                    let username;
                    let password;
                    for (let i = 0; i < this.toolbarAttributes.CallData.length; i++) {
                        console.log('******postIF Inbound21');
                        if (this.toolbarAttributes.CallData[i].name == 'SF_USERNAME') {
                            console.log('******postIF Inbound21');
                            username = this.toolbarAttributes.CallData[i].value;
                        }
                        if (this.toolbarAttributes.CallData[i].name == 'SF_PASSWORD') {
                            password = this.toolbarAttributes.CallData[i].value;
                        }
                    }
                    console.log('******postIF Inbound3');
                    console.log('******postIF Inbound3:' + username);
                    console.log('******postIF Inbound3:' + password);
                    let searchparams2 = 'filter={"filter":{"uuid":"' + this.uuid + '"},"sort":{"startTs":-1},"index":0}'   ; 
                    let searchparams = encodeURI(searchparams2);
                    let reiteklink = 'https://herapresfdc.cloudando.com/ctreplay/externalView/search?' + searchparams;//this.regLink.replace(url.searchParams.get('filter'), newparams);
                    createActivityInbound({
                        //startCall: startCallDateTime,
                        'reiteklink': reiteklink,
                        'username' : username,
                        'password' : password
                    }).then(data => {
                        console.log('******postIF Inbound4');
                        console.log('******createActivity --- OrderId - ' + JSON.stringify(data));
                        // this.activityId = data.Id;
                        // console.log('CAMPAINGCHECK:' + this.campaignMemberId);
                    // var hostname = window.location.hostname;
                    /*   var arr = hostname.split(".");
                        var instance = arr[0];
                        console.log("*******Instance:" + instance);*/
                        console.log("PRIMA DI REDIRECT");
                        if(data != null){
                            window.open("/s/order/" + data, "_self");
                        }
                    }).catch(err => {
                        console.log(JSON.stringify(err));
                    });
                } else {
                    let ecid = window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                    this.ecid = ecid;// window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID")

                    if (this.ecid != '' && this.objectApiName == 'CampaignMember') {
                        this.showRecallMe = true;
                    }

                    console.log('window.TOOLBAR.EASYCIM.openScript --> params: uuid =' + this.uuid + ', ecid = ' + this.ecid);
                    let promise = window.TOOLBAR.EASYCIM.openScript(this.uuid, this.ecid, false);
                    setTimeout(() => {
                        console.log("TIMOUT 20 SEC");
                        console.log('PROMISE');
                        console.log(promise);
                    }, 20000);
                    promise.then(data => {
                        console.log('******DATAOPENSCRIPT:');
                        console.log(data);
                        window.TOOLBAR.AGENT.getAgentID()
                        .then(agentId => {
                            console.log("data.listFieldValueList:");
                            // console.log(dataArray);
                            data.listFieldValueList.forEach(field => {
                                if (field.fieldName == 'campaignmemberid' || field.fieldName == 'campaignMemberId') {
                                    console.log('campaignMemberId: ' + field.value);
                                    let phoneNum = event.detail.eventObj.dnis
                                    let searchparams2 = 'filter={"filter":{"ecid":"' + ecid + '"},"sort":{"startTs":-1},"index":0}';
                                    let searchparams = encodeURI(searchparams2);
                                    let reiteklink = 'https://herapresfdc.cloudando.com/ctreplay/externalView/search?' + searchparams;
                                    this.registrationLinkVo = reiteklink;

                                    createActivity({
                                        'clientNumber': String(phoneNum),
                                        'registrationLink': reiteklink,
                                        'ecid': ecid,
                                        'campaignMemberId': field.value,
                                        'agent': agentId
                                    })
                                    .then(data => {
                                        this.activityId = data.Id;
                                        window.open("/s/campaignmember/" + field.value, "_self");
                                    })
                                    .catch(error => console.error(error));
                                }
                            });
                        });
                    }, error => {
                        console.log('ERROR')
                        console.log(error)
                    });
                    // .catch(error => {
                    //     console.log(error);
                    // });
                }
                break;
            case 'ESTABLISHED':
                console.log('*******INSIDE_ESTABLISHED');
                break;
            default:
                break;
        }
    }

    callThisNumber() {
        this.template.querySelector("c-hdt-ct-toolbar").callNumberFromParent(this.numberToCall);
    }

    getAgentUsername() {
        window.TOOLBAR.AGENT.getAgentID().then(
            function (data) {
                console.log('******DATAOPENSCRIPT:' + JSON.stringify(data));
                return data;
            });
    }

    @api saveScript(esito, isResponsed) {
        // let doSaveScript = ((cachedUuid, esito, isResponsed) => {
        //     window.TOOLBAR.EASYCIM.saveScript(cachedUuid, esito, isResponsed)
        //     .then(() => this.saveScriptDone = true);
        // })

        // if(!this.uuid) {
            console.log('INSIDE SAVESCRIPT');
            getCachedUuid().then(cachedUuid => {
                console.log('getCachedUuid().then' + cachedUuid);
                window.TOOLBAR.EASYCIM.saveScript(cachedUuid, esito, isResponsed)
                .then(() => {
                    console.log('getCachedUuid().then savescript.then()' + cachedUuid);
                    this.saveScriptDone = true;
                });
            });
        // } else {
        //     window.TOOLBAR.EASYCIM.saveScript(this.uuid, esito, isResponsed)
        //     .then(() => {
        //         this.saveScriptDone = true;
        //     });
        // }
    }

    @api getSlot() {
        console.log('getSlot');
        /* window.TOOLBAR.AGENT.getAgentID().then(
             function (data) {
                 this.agentidc = data
                 console.log("agentUserId:" + data);
                 console.log("agentUserId:" + this.agentidc);
             })*/
        this.dispatchEvent(new CustomEvent('showpopup'));
    }

    @api getSlotConfirm(startRange) {
        console.log(this.campaignMemberId);
        console.log(startRange);
        //let st = startRange;
        //let cmm = this.campaignMemberId;
        // window.TOOLBAR.AGENT.getAgentID().then(
        //  function (data) {
        // console.log('******DATAOPENSCRIPT:' + JSON.stringify(data));
        console.log('startRange: ' + startRange);
        //  console.log('idUser: ' + this.agentidc);
        console.log('campaignMemberId: ' + this.campaignMemberId);
        postSlotRequest({
            startRange: startRange,
            campaignMemberId: this.campaignMemberId
        }).then((data) => {
            console.log(JSON.stringify(data));
            let response = data;
            this.dispatchEvent(new CustomEvent('showpopupslot', { detail: { data } }));
        });
        //});
    }

    @api sendStatus(ecid) {
        getStatus({
            ecid: ecid
        }).then((response) => {
            console.log('******' + response);
            if (response != '' && response != null) {
                this.saveScript(response, true);
            } else {
                this.isHide = true;
            }
            // console.log('CAMPAINGCHECK:' + this.campaignMemberId);
            // break;
        });
    }

    hangup() {
        this.template.querySelector("c-hdt-ct-toolbar").hangUpFromParent();
    }

    @api postAppointmentRequest(selectedTimeSlot) {
        console.log('campaignMemberId: ' + this.campaignMemberId);
        console.log("TRYHERE:" + selectedTimeSlot);
        postAppointment({
            appointment: selectedTimeSlot,
            appointmentType: 'PERSONALE',
            campaignMemberId: this.campaignMemberId
        }).then(data => {
            console.log(JSON.stringify('postAppointment response: ' + data));
            if (data == 'success') {
                
                //update campaignMember status
                //this.saveScript('Appuntamento telefonico personale', true);
                this.updateMemberStatus('Appuntamento telefonico personale');
            }
        }).catch(err => {
            const event = new ShowToastEvent({
                title: 'Errore!',
                variant: 'error', 
                message: 'Non è stato possibile completare l\'operazione',
            });
            this.dispatchEvent(event);

            console.log(JSON.stringify(err));

        })
        //  });
    }

    trackActivity(action) {
        if (action == 'createActivity') {
            let url = new URL(this.regLink);
            let searchparams = JSON.parse(url.searchParams.get('filter'));
            searchparams.filter.ecid = this.ecid;
            let newparams = JSON.stringify(searchparams);
            this.registrationLinkVo = this.regLink.replace(url.searchParams.get('filter'), newparams);
            let reiteklink = this.registrationLinkVo;
            const event = new CustomEvent('getreiteklink', {
                detail: { reiteklink }
            });
            this.dispatchEvent(event);

           /* createActivity({
                startCall: this.startCallDateTime,
                clientNumber: this.numberToCall,
                registrationLink: this.registrationLinkVo,
                ecid: this.ecid,
                campaignMemberId: this.campaignMemberId
            }).then(data => {
                console.log('createActivity --- ' + JSON.stringify(data));
                this.activityId = data.Id;
            }).catch(err => {
                console.log(JSON.stringify(err));
            });*/

        } else if (action == 'updatectivity') {
            updateActivity({
                activityId: this.activityId,
                endCall: this.endCallDateTime,
                callDuration: this.callDuration,
                waitingTime: this.waitingTime
            }).then(data => {
                console.log('updateActivity --- ' + JSON.stringify(data));
            }).catch(err => {
                console.log(JSON.stringify(err));
            });
        }
    }

    updateMemberStatus(status) {
        updateCampaignMemberStatus({
            status: status,
            campaignMember: this.campaignMemberId,
            isToSendStatusReitek: true
        }).then(data => {
            if (data) {
                const event = new ShowToastEvent({
                    title: 'Success!',
                    variant: 'success', 
                    message: 'Operazione completata con successo',
                });
                this.dispatchEvent(event);

                console.log('stato aggiornato con successo');
            }
        }).catch(err => {
            const event = new ShowToastEvent({
                title: 'Errore!',
                variant: 'error', 
                message: 'Non è stato possibile completare l\'operazione',
            });
            this.dispatchEvent(event);
            console.log(JSON.stringify(err));
        });
    }
}