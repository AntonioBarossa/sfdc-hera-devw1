import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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

export default class HdtCtToolbarContainer extends NavigationMixin(LightningElement) {

    showPanel = false;
    numberToCall = '';
    @api objectApiName;
    @track showRecallMe = false;
    @track showModal = false;
    @track toolbarAttributes = [];
    @track uuid = '';
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
    showmessage;
    message;
    variant;

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
        console.log('****BEFORESAVE:' + this.uuid);
        window.TOOLBAR.EASYCIM.saveScript('68-60f69967@pddialer1.saashra.priv', "Appuntamento telefonico personale", true);
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
                this.uuid = this.toolbarAttributes.id;
                if (this.toolbarAttributes.type != null && this.toolbarAttributes.type != undefined && this.toolbarAttributes.type == 'inbound') {

                    this.saveScript('Positivo', true);
                }
                else {
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
                break;
            case 'POPUP':
                //if (count == 0) {
                console.log('*******INSIDEPOPUP');
                this.toolbarAttributes = event.detail.eventObj;
                this.uuid = this.toolbarAttributes.id;
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

                }
                else{
                    let ecid = window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                    this.ecid = ecid;// window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID")

                    if (this.ecid != '' && this.objectApiName == 'CampaignMember') {
                        this.showRecallMe = true;
                    }

                    //update sale record adding ecid value
                /* if (this.saleId != null && this.ecid != null) {
                        saveEcidInSales({ 'saleId': this.saleId, 'ecid': this.ecid }).then(data => {
                            if (data) {
                                console.log('Ecid saved in Sale ' + this.saleId);
                            }
                        }).catch(err => {
                            console.log(JSON.stringify(err));
                        })
                    }*/

                    window.TOOLBAR.EASYCIM.openScript(this.uuid, this.ecid, false).then(
                        function (data) {
                            console.log('******DATAOPENSCRIPT:' + JSON.stringify(data));
                            window.TOOLBAR.AGENT.getAgentID().then(
                                function (data2) {
                                    let dataArray = data.listFieldValueList;
                                    console.log("******DataArray:" + dataArray);
                                    for (let i = 0; i < dataArray.length; i++) {
                                        if (dataArray[i].fieldName == 'campaignmemberid' || dataArray[i].fieldName == 'campaignMemberId') {
                                            this.campaignMemberId = dataArray[i].value;
                                            console.log('campaignMemberId' + this.campaignMemberId);
                                            console.log('ecid' + this.ecid);
                                            let phoneNum = event.detail.eventObj.dnis
                                            console.log('******ecid' + ecid);
                                            console.log('*****:1');
                                            //let startCallDateTime = event.detail.eventObj.startTime;
                                            console.log('*****:2');
                                            //this.startCallDateTime = null;
                                            console.log('*****:3');
                                        // let url = new URL(this.regLink);
                                            console.log('*****:4');
                                        // let searchparams3 = this.regListParam;
                                            console.log('*****:4.1');
                                            let searchparams2 = 'filter={"filter":{"ecid":"' + ecid + '"},"sort":{"startTs":-1},"index":0}'   ; 
                                            console.log('*****:5 : ' + searchparams2);
                                            let searchparams = encodeURI(searchparams2);
                                            //searchparams.filter.ecid = this.ecid;
                                            console.log('*****:6 ' + searchparams);
                                            //let newparams = JSON.stringify(searchparams);
                                            console.log('*****:7');
                                            let reiteklink = 'https://herapresfdc.cloudando.com/ctreplay/externalView/search?' + searchparams;//this.regLink.replace(url.searchParams.get('filter'), newparams);
                                            console.log('*****:8');
                                            this.registrationLinkVo = reiteklink;
                                            console.log('*****:9');
                                            /*const event = new CustomEvent('getreiteklink', {
                                                detail: { reiteklink }
                                            });
                                            this.dispatchEvent(event);
                                            */

                                            console.log('*****:10:' + phoneNum);
                                            console.log('*****:10:' + reiteklink);
                                            console.log('*****:10:' + ecid);
                                            console.log('*****:10:' + this.campaignMemberId);
                                            console.log('*****:10:' + data2);


                                            createActivity({
                                                //startCall: startCallDateTime,
                                                'clientNumber': phoneNum +'',
                                                'registrationLink': reiteklink,
                                                'ecid': ecid,
                                                'campaignMemberId': this.campaignMemberId,
                                                'agent': data2
                                            }).then(data => {
                                                console.log('******createActivity --- ' + JSON.stringify(data));
                                                this.activityId = data.Id;
                                                console.log('CAMPAINGCHECK:' + this.campaignMemberId);
                                            // var hostname = window.location.hostname;
                                            /*   var arr = hostname.split(".");
                                                var instance = arr[0];
                                                console.log("*******Instance:" + instance);*/
                                                console.log("PRIMA DI REDIRECT");
                                                window.open("/s/campaignmember/" + this.campaignMemberId, "_self");
                                            }).catch(err => {
                                                console.log(JSON.stringify(err));
                                            });

                                        /*   saveEcid({
                                                'ecid': ecid,
                                                'campaignMember': this.campaignMemberId,
                                                'agent': data2
                                            }).then((response) => {

                                                console.log('CAMPAINGCHECK:' + this.campaignMemberId);
                                                var hostname = window.location.hostname;
                                                var arr = hostname.split(".");
                                                var instance = arr[0];
                                                console.log("*******Instance:" + instance);
                                                console.log("PRIMA DI REDIRECT");
                                                window.open("/s/campaignmember/" + this.campaignMemberId, "_self");*/
                                                /* this[NavigationMixin.Navigate]({
                                                    type: 'comm__namedPage',
                                                    attributes: {
                                                    name: 'Campaign_Member_Detail__c',
                                                    },
                                                    state: {
                                                    'recordId': this.campaignMemberId
                                                    }
                                                    });*/
                                                /* this[NavigationMixin.Navigate]({
                                                    type:'comm__namedPage',
                                                    attributes:{
                                                        "pageName" :'Campaign_Member_Detail__c'
                                                    }
                                                });*/
                                        //   });
                                        }
                                    }
                                });
                        }, function (err) { console.log("*******ErrorOpenScript:", err); }
                    );
                }
                break;
            case 'ESTABLISHED':
                console.log('*******INSIDE_ESTABLISHED');
               // this.startCallDateTime = event.detail.eventObj.startTime;
               // this.trackActivity('createActivity');
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
        window.TOOLBAR.EASYCIM.saveScript(this.uuid, esito, isResponsed);
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
        }).then((data) => {
            console.log(JSON.stringify('postAppointment response: ' + data));
            if (data) {
                //update campaignMember status
                //this.saveScript('Appuntamento telefonico personale', true);
                this.updateMemberStatus('Appuntamento telefonico personale');
            }
            else{
                this.setmessage(true);
                console.log('postAppointment->else');
            }
        }).catch((err) => {
            this.setmessage(true);
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
        }).then((data) => {
            if (data) {
                this.setmessage(false);
                console.log('stato aggiornato con successo');
            }
            else{
                this.setmessage(true);
                console.log('Updatemember->else');
            }
        }).catch((err) => {
            this.setmessage(true);
            console.log(JSON.stringify(err));
        });
    }

    setmessage(isError){
        if(isError){
            this.showmessage=true;
            this.message='Non è stato possibile completare l\'operazione!';
            this.variant='error';
        }
        else{
            this.showmessage=true;
            this.message='Operazione completata con successo';
            this.variant='success';
        }
    }

    cancelEvent(event){
        this.params = {};
        if(event.detail === false){
            this.showmessage=false;         
        }
    }
    
}