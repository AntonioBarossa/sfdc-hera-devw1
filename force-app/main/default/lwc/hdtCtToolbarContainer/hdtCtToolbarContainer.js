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
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';    // params: n/a
import getEcid from '@salesforce/apex/HDT_LC_CampaignsController.getEcid';


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
    @api regLink = 'https://heraprosfdc.cloudando.com/ctreplay/externalView/search?filter={"filter":{"ecid":""},"sort":{"startTs":-1},"index":0}';
    @api regLinkHost = 'https://heraprosfdc.cloudando.com/ctreplay/externalView/search?';
    @api regListParam = 'filter={"filter":{"ecid":"[PLACE]"},"sort":{"startTs":-1},"index":0}';
    @track registrationLinkVo;
    @track saleId;
    @track firstLoginTime;
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
        ]).then(() => {
            console.log('# javascript Loaded #');
            setTimeout(() => {
                this.getFirstLoginTime();        
            }, 1000);
            
        }).catch(error => console.log('promise error: ' + error));

        //get saleId if in wizard-vendita page
        if (location.href.indexOf('wizard-vendita') > 0) {
            let currentUrl = new URL(location.href);
            this.saleId = currentUrl.searchParams.get('c__saleId');
        }
    }

    getFirstLoginTime(){

        try{

            console.log('ENTRATO IN getFirstLoginTime');

            let getAgentIDPromise =  window.TOOLBAR.AGENT.getAgentID();
            console.log('getFirstLoginTime PUNTO 1');

            let isTimeOver = false;

            console.log('getFirstLoginTime PUNTO 1B');

            let timeout = setTimeout(() => {
                console.log("Scattato il timeout della promise, verrà eseguito il codice del timeout");
                isTimeOver = true;
            }, 2000);
            
            console.log('DOPO TIMEOUT');

            getAgentIDPromise.then((data) => {
                console.log('getFirstLoginTime PUNTO 2');
                window.clearTimeout(timeout);
                console.log('getFirstLoginTime PUNTO 3');
                if (!isTimeOver) {
                    console.log('getAgentID SUCCESS');
                    if (typeof data !== "undefined") {
                        console.log('data != undefined');
                        window.TOOLBAR.AGENT.getAgentStateByID(data).then((agentState) => {
                            console.log('getAgentStateByID SUCCESS');
                            if (typeof agentState === "object") {
                                console.log('agentState = OBJECT');
                                console.log("ID:", agentState.ID, "FirstLoginTime:", agentState.FirstLoginTime, "agentState:", agentState);
                                this.firstLoginTime = agentState.FirstLoginTime;
                                console.log('this.firstLoginTime  --> '+this.firstLoginTime);

                                console.log('ARRIVATO PRIMA DI LANCIO CHECK OPEN SCRIPT');
                            }
                        }).bind(this), error => {
                            console.log('getAgentStateByID ERROR');
                            console.log(error)
                        };
                    }
                    console.log("Promise risolta, codice eseguito");
                } else {
                    isTimeOver = false;
                    console.log("Promise risolta dopo il timeout, NON è stato eseguita il codice nella THEN");
                }
            });               
        }
        catch(error){
            console.error('ERRORE : ',error);
            alert('TEMPO TROPPO BASSO');
        }
    }

    toolbarEvent(event) {
        console.log('>>> toolbarEvent');
        console.log('********** EVENT TYPE > ' + event.detail.eventType);
        console.log('>>> EVENT OBJ > ' + JSON.stringify(event.detail.eventObj));

        let eventType = event.detail.eventType;
        eventType = eventType.toUpperCase();
        let callData = [];
        let ecid = '';
        let count = 0;
        console.log("######:" + eventType)
        console.log("JOB TYPE .--> " + event.detail.eventObj.job_type);
        
            switch (eventType) {
                case 'CONNECTIONCLEARED':
                    if(event.detail.eventObj.job_type !== 'manual'){
                        console.log('AUTO 1 CONNECTIONCLEARED ESEGUITA');
                        console.log("*****DentroConnection");
                        this.toolbarAttributes = event.detail.eventObj;
                        if(this.toolbarAttributes.id) {
                            this.uuid = this.toolbarAttributes.id;
                        }
                        if (this.toolbarAttributes.type != null && this.toolbarAttributes.type != undefined && this.toolbarAttributes.type == 'inbound') {
                           // console.log('ctToolbarContainer ENTRATO IN saveScript POSITIVO');
                           // this.saveScript('Positivo', true);
                        } else {
                            callData = event.detail.CallData;
                            this.endCallDateTime = this.toolbarAttributes.endTime;
                            this.callDuration = this.toolbarAttributes.time_duration_sec != null ? (parseInt(this.toolbarAttributes.time_duration_sec) / 60).toFixed(2) : 0; // convert in minutes
                            this.waitingTime = this.toolbarAttributes.waitingTime != null ? (parseInt(this.toolbarAttributes.waitingTime) / 60).toFixed(2) : 0; // convert in minutes
                            let ecid2 = window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                            this.ecid = ecid2;
                            console.log('*********ConnectionCleared:2' + ecid2);
                            //this.sendStatus(ecid2);
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
                        if(this.saveScriptDone || localStorage.getItem("openScript-"+this.ecid) == null) {
                            console.log('BEFORE OFFLINEEND : '+event.detail.eventObj.id);
                            window.TOOLBAR.CONTACT.OfflineEnd(event.detail.eventObj.id);
                            console.log('OFFLINEEND DONE');
                        }
                        
                        this.saveScriptDone = false;
                    }
                    break;
                case 'POPUP':
                    if(event.detail.eventObj.job_type !== 'manual'){
                        console.log('AUTO 1 POPUP ESEGUITA');
                        this.toolbarAttributes = event.detail.eventObj;
                        console.log('this.toolbarAttributes --> '+this.toolbarAttributes);
                        this.uuid = this.toolbarAttributes.id;
                        callData = event.detail.CallData;
                        console.log('this.toolbarAttributes.type --> '+this.toolbarAttributes.type);
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
                                    console.log('*******INSIDEPOPUP PUNTO 4');
                                    password = this.toolbarAttributes.CallData[i].value;
                                }
                            }
                            console.log('******postIF Inbound3');
                            console.log('******postIF Inbound3:' + username);
                            console.log('******postIF Inbound3:' + password);
                            let searchparams2 = 'filter={"filter":{"uuid":"' + this.uuid + '"},"sort":{"startTs":-1},"index":0}'   ; 
                            console.log('*******INSIDEPOPUP PUNTO 5');
                            let searchparams = encodeURI(searchparams2);
                            console.log('*******INSIDEPOPUP PUNTO 6');
                            let reiteklink = 'https://heraprosfdc.cloudando.com/ctreplay/externalView/search?' + searchparams;//this.regLink.replace(url.searchParams.get('filter'), newparams);
                            console.log('*******INSIDEPOPUP PUNTO 7');
                            createActivityInbound({
                                //startCall: startCallDateTime,
                                'reiteklink': reiteklink,
                                'username' : username,
                                'password' : password
                            }).then(data => {
                                console.log('******postIF Inbound4');
                                console.log('******createActivity --- OrderId - ' + JSON.stringify(data));
                                if(data != null){
                                    window.open("/HC/s/order/" + data, "_self");
                                }
                            }).catch(err => {
                                console.log('*******INSIDEPOPUP PUNTO 8');
                                console.log(JSON.stringify(err));
                            });
                        } else {
                            console.log('*******INSIDEPOPUP PUNTO 9');
                            let ecid = window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                            console.log('*******INSIDEPOPUP PUNTO 10');
                            this.ecid = ecid;// window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID")
                            console.log('*******INSIDEPOPUP PUNTO 11');
                            if (this.ecid != '' && this.objectApiName == 'CampaignMember') {
                                console.log('*******INSIDEPOPUP PUNTO 12');
                                this.showRecallMe = true;
                            }
                            console.log('*******INSIDEPOPUP PUNTO 13');
                            console.log('window.TOOLBAR.EASYCIM.openScript --> params: uuid =' + this.uuid + ', ecid = ' + this.ecid);

                            //getEcid({ 'campaignMemberId': this.campaignMemberId}).then(data => {
                                let submitEcid;
                                //console.log("ctToolbarContainer launch SUCCESS --> " + JSON.stringify(data));
                                if(this.ecid!=null){
                                    submitEcid=this.ecid;
                                }
                                /*else{
                                    submitEcid = data;
                                }*/
                                console.log('ctToolbarContainer submitEcid --> '+submitEcid);
                                if(submitEcid === null || submitEcid === undefined || submitEcid === ''){                
                                    console.log('### ctToolbarContainer ERRORE! Numero e/o ecid non trovati ###');
                                    console.log('### ctToolbarContainer this.ecid --> ',this.ecid,' ###');
                                    const evt = new ShowToastEvent({
                                        title: 'Attenzione!',
                                        message: 'Ecid non trovato. Verificare e riprovare.',
                                        variant: 'warning',
                                        mode: 'dismissable'
                                    });
                                    this.dispatchEvent(evt);
                                    
                                }
                                else{
                                    console.log('ECID TROVATO PUNTO 1');
                                    //openScriptNotPresent = this.checkOpenScript();
                                    let openScriptNotPresent;
                                    //CONTROLLO OPENSCRIPT INIZIO
                                    let ecidLoginTime;
             
                                    console.log('ECID TROVATO PUNTO 2 : submitEcid --> '+submitEcid);
                                    if(localStorage.getItem("openScript-"+submitEcid) != null){
                                        console.log('ECID TROVATO PUNTO 3');
                                        ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);
                                        console.log('ECID TROVATO PUNTO 4 : ecidLoginTime --> '+ecidLoginTime);
                                        console.log('ECID TROVATO PUNTO 5 : this.firstLoginTime --> '+this.firstLoginTime);

                                        if(ecidLoginTime < this.firstLoginTime){
                                            console.log('ECID TROVATO PUNTO 6');
                                            localStorage.removeItem("openScript-"+submitEcid);
                                            console.log('ECID TROVATO PUNTO 7');
                                            openScriptNotPresent = true;
                                        }
                                        else{
                                            console.log('ECID TROVATO PUNTO 8');
                                            openScriptNotPresent = false;
                                        }
                                    }
                                    else{
                                        console.log('ECID TROVATO PUNTO 9');
                                        openScriptNotPresent = true;
                                    }
                                    //CONTROLLO OPENSCRIPT FINE
                                    console.log('ECID TROVATO PUNTO 10 : openScriptNotPresent --> '+openScriptNotPresent);

                                    if(openScriptNotPresent === true){
                                        console.log("ECID TROVATO PUNTO 11 openScriptNotPresent a true");
                                
                                        let promise = window.TOOLBAR.EASYCIM.openScript("", this.ecid, false);
                                        console.log("ECID TROVATO PUNTO 12 PRIMA DI PROMISE.THEN");

                                        setTimeout(() => {
                                            console.log("TIMOUT 20 SEC");
                                            console.log('PROMISE');
                                            console.log(promise);
                                        }, 20000);

                                        promise.then(data => {
                                            console.log('ctToolbarContainer POPUP OPENSCRIPT ESEGUITA');
                                            console.log('ECID TROVATO PUNTO 13');
                                            console.log('ECID TROVATO PUNTO 14 PROMISE DATA --> '+data);
                                            console.log('ECID TROVATO PUNTO 15 this.ecid --> '+this.ecid);
            
                                            if(data && data.result == true && data.terminated != true && data.readOnly != true){
                                                console.log('ECID TROVATO PUNTO 16 checkOpenScript data OK');
                                                localStorage.setItem("openScript-"+this.ecid , Date.now());
                                                console.log('## ECID TROVATO PUNTO 17 checkOpenScript data --> '+JSON.stringify(data));
                                                console.log('## ECID TROVATO PUNTO 18 checkOpenScript data.result --> '+data.result);
                                                console.log('## ECID TROVATO PUNTO 19 checkOpenScript data.terminated --> '+data.terminated);
                                                console.log('## ECID TROVATO PUNTO 20 checkOpenScript data.readOnly --> '+data.readOnly);
                                                console.log('checkOpenScript value saved --> ',localStorage.getItem("openScript-"+this.ecid));
                                                console.log('### checkOpenScript PUNTO 10 : data --> ',data,' ###');   
                                            }
                                            else{
                                                console.log('#### checkOpenScript PUNTO 10.1 ####');
                                                console.log('## checkOpenScript readOnly = true #');
                                                console.log('## checkOpenScript data --> '+JSON.stringify(data));
                                                console.log('## checkOpenScript data.result --> '+data.result);
                                                console.log('## checkOpenScript data.terminated --> '+data.terminated);
                                                console.log('## checkOpenScript data.readOnly --> '+data.readOnly);
                                                //####  blocco attività  ####
                                                try {
                                                    console.log('### checkOpenScript PUNTO 10.2 ###');
                                                    //alert("Errore! Non puoi effettuare la chiamata in questo momento.");
                                                    const evt = new ShowToastEvent({
                                                        title: 'Errore',
                                                        message: 'Il contatto è in gestione lato EasyCIM da altro operatore.',
                                                        variant: 'warning',
                                                        mode: 'dismissable'
                                                    });
                                                    this.dispatchEvent(evt);
                                                    console.log('#### checkOpenScript PUNTO 11 ####');
                                                } catch (error) {
                                                    console.error('checkOpenScript ERRORE --> ',error);
                                                }
                                            }
                                            window.TOOLBAR.AGENT.getAgentID()
                                            .then(agentId => {
                                                console.log("data.listFieldValueList:");
                                                // console.log(dataArray);
                                                data.listFieldValueList.forEach(field => {
                                                    console.log('*******INSIDEPOPUP PUNTO 15');
                                                    if (field.fieldName == 'campaignmemberid' || field.fieldName == 'campaignMemberId') {
                                                        console.log('*******INSIDEPOPUP PUNTO 16');
                                                        console.log('campaignMemberId: ' + field.value);
                                                        let phoneNum = event.detail.eventObj.dnis;
                                                        console.log('*******INSIDEPOPUP PUNTO 17');
                                                        let searchparams2 = 'filter={"filter":{"ecid":"' + ecid + '"},"sort":{"startTs":-1},"index":0}';
                                                        console.log('*******INSIDEPOPUP PUNTO 18');
                                                        let searchparams = encodeURI(searchparams2);
                                                        console.log('*******INSIDEPOPUP PUNTO 19');
                                                        let reiteklink = 'https://heraprosfdc.cloudando.com/ctreplay/externalView/search?' + searchparams;
                                                        console.log('*******INSIDEPOPUP PUNTO 20');
                                                        this.registrationLinkVo = reiteklink;
                                                        console.log('*******INSIDEPOPUP PUNTO 21');
                                                        createActivity({
                                                            'clientNumber': String(phoneNum),
                                                            'registrationLink': reiteklink,
                                                            'ecid': ecid,
                                                            'campaignMemberId': field.value,
                                                            'agent': agentId
                                                        })
                                                        .then(data => {
                                                            console.log('*******INSIDEPOPUP PUNTO 22');
                                                            this.activityId = data.Id;
                                                            window.open("/HC/s/campaignmember/" + field.value, "_self");
                                                        })
                                                        .catch(error => console.error(error));
                                                    }
                                                });
                                            });
                                        }, error => {
                                            console.log('ERROR')
                                            console.log(error)
                                        });                      
                                    }
                                    else{
                                        console.log('openScript non eseguita perché già effettuata');
                                    }
                                }
                            /*}),error => {
                                console.log('ctToolbarContainer ERROR');
                                console.log(error);
                            };    */     
                        }
                    }
                    break;
                case 'ESTABLISHED':
                    if(event.detail.eventObj.job_type !== 'manual'){
                        console.log('AUTO 1 ESTABLISHED ESEGUITA');
                        console.log('*******INSIDE_ESTABLISHED');
                        console.log('### this.ecid --> '+this.ecid);
                    }
                    break;
                case 'AGENT:LOGGEDOUT':         
                    console.log('AUTO 1 AGENT:LOGGEDOUT ESEGUITA');
                    localStorage.clear();
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

    @api saveScript(ecid, esito, isResponsed) {

            let submitEcid = ecid;
            let openScriptNotPresent;
            console.log('INSIDE SAVESCRIPT');
            console.log('submitEcid --> '+submitEcid);
            // HRADTR_GV 13/04/23

            openScriptNotPresent = this.checkOpenScript(submitEcid);

            if(openScriptNotPresent === true){

                window.TOOLBAR.EASYCIM.openScript("", submitEcid, true).then((data => {
                    console.log('ctToolbarContainer saveScript OPENSCRIPT ESEGUITA');
                    if(data && data.result === true && data.terminated != false && data.readOnly != true){
                        console.log('data OK');
                        localStorage.setItem("openScript-"+submitEcid , Date.now());
                        console.log('SAVESCRIPT RESULT 1A localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                        window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed)
                        .then((data) => {
                            console.log('SAVESCRIPT RESULT DATA --> '+data);
                            if(data){
                                localStorage.removeItem("openScript-"+submitEcid);
                                console.log('SAVESCRIPT RESULT 1B localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                            }
                            console.log('SAVESCRIPT DONE');
                            this.saveScriptDone = true;
                        });
                        console.log('value saved --> ',localStorage.getItem("openScript-"+submitEcid));
                        console.log('### PUNTO 10 : data --> ',data,' ###');   
                    }
                    else{
                        console.log('#### PUNTO 10.1 ####');
                        console.log('## readOnly = true #');
                        console.log('## data --> '+data);
                        //####  blocco attività  ####
                        try {
                            console.log('isModalOpen --> ',this.isModalOpen);
                            console.log('### PUNTO 10.2 ###');
                            //alert("Errore! Non puoi effettuare la chiamata in questo momento.");
                            const evt = new ShowToastEvent({
                                title: 'Errore',
                                message: 'Il contatto è in gestione lato EasyCIM da altro operatore.',
                                variant: 'warning',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                            console.log('#### PUNTO 11 ####');
                        } catch (error) {
                            console.error('ERRORE --> ',error);
                        }
                    }
                    
                }).bind(this), error => {
                    console.log('ERROR')
                    console.log(error)
                });
            }
            else{
                console.log('CheckOpenScript false');
                console.log('SAVESCRIPT RESULT 2A localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed)
                .then((data) => {
                    console.log('SAVESCRIPT RESULT 2 DATA --> '+data);
                    if(data){
                        localStorage.removeItem("openScript-"+submitEcid);
                        console.log('SAVESCRIPT RESULT 2B localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                    }
                    console.log('SAVESCRIPT DONE');
                    this.saveScriptDone = true;
                });
            }
        // } else {
        //     window.TOOLBAR.EASYCIM.saveScript(this.uuid, esito, isResponsed)
        //     .then(() => {
        //         this.saveScriptDone = true;
        //     });
        // }
    }

    checkOpenScript(reitekEcid){

        let ecidLoginTime;
        let submitEcid = reitekEcid;

        console.log('PUNTO 1');
        console.log('PUNTO 2 : submitEcid --> '+submitEcid);
        if(localStorage.getItem("openScript-"+submitEcid) != null){
            console.log('PUNTO 3');
            ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);
            console.log('PUNTO 4 : ecidLoginTime --> '+ecidLoginTime);
            console.log('PUNTO 5 : this.firstLoginTime --> '+this.firstLoginTime);

            if(ecidLoginTime < this.firstLoginTime){
                console.log('PUNTO 6');
                localStorage.removeItem("openScript-"+submitEcid);
                console.log('PUNTO 7');
                return true;
            }
            else{
                console.log('PUNTO 8');
                return false;
            }
        }
        else{
            console.log('PUNTO 9');
            return true;
        }

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
            console.log('kkk prima di savesript' + response);

            if (response != '' && response != null) {
                this.saveScript(ecid, response, true);
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
                if(this.ecid){
                    this.sendStatus(this.ecid);
                }
                else{
                    getEcid({ 'campaignMemberId': this.campaignMemberId}).then(data => {
                        this.ecid=data;
                        this.sendStatus(this.ecid);
                    }),error => {
                        console.log('ctToolbarContainer ERROR');
                        console.log(error);
                    }; 
                }
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