import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import cacheUuid from '@salesforce/apex/HDT_LC_CtToolbar.cacheUuid';    // params: uuid
import getCampaignTipology from '@salesforce/apex/HDT_LC_CampaignsController.getCampaignTipology';
import getPhoneNumber from '@salesforce/apex/HDT_LC_CampaignsController.getCampaignMemberPhone';
import getEcid from '@salesforce/apex/HDT_LC_CampaignsController.getEcid';
import createActivity from '@salesforce/apex/HDT_LC_CtToolbar.createActivity';
import getStatus from '@salesforce/apex/HDT_LC_CtToolbar.getStatusByEcid';
import updateActivity from '@salesforce/apex/HDT_LC_CtToolbar.updateActivity';

var DataObj;

export default class HdtCampaignMemberVenditaTeleselling extends LightningElement {

    @api recordId;
    @track phoneNumber;
    @track ecid;
    contacts;
    contactId;
    contattoGestito = false;
    jsonRequest;
    isModalOpen = false;
    firstLoginTime;
    tipology;
    @track phoneNumberBoxEnabled;
    @track toolbarAttributes = [];
    agentId='';

    numberToCall = '';
    iconName = '';
    agentStatus = '';
    spinner = true;
    dialing = false;
    title = 'Scheda cliente';
    saveScriptDone;
    @track registrationLinkVo;
    @track activityId;
    @track endCallDateTime;
    @track waitingTime;
    @track callDuration;

    enableClickToCall(){
        getPhoneNumber({ 'campaignMemberId': this.recordId}).then(data => {
            console.log("getPhoneNumber launch SUCCESS --> " + JSON.stringify(data));

            if(this.tipology === 'Comfort Call' || this.tipology === 'Quality Call'){
                console.log('ABILITATO');
                this.phoneNumberBoxEnabled = false;
            }
            else{
                console.log('DISABILITATO');
                this.phoneNumberBoxEnabled = true;
            }

            this.phoneNumber = data;
            this.checkEcid();

            if(this.phoneNumber === null || this.phoneNumber === undefined || this.phoneNumber === ""){
                const evt = new ShowToastEvent({
                    title: 'Attenzione!',
                    message: 'Nessun numero trovato. Verificare e riprovare.',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }

            this.isModalOpen = true;

            
        }).catch(err => {
            console.log(err);
        }); 
    }

    connectedCallback(){

        console.log('# connectedCallback #');
        this.iconName = 'utility:log_a_call';
        this.agentStatus = 'standard:employee_contact';
        console.log('# PUNTO 1 #');

        getCampaignTipology({ 'campaignMemberId': this.recordId}).then(data => {
            console.log('PUNTO 1B');
            console.log('data --> '+data);
            this.tipology = data;
            console.log('this.tipology --> '+this.tipology);
        }).catch(err => {
            console.log(err);
        }); 

        window.addEventListener('toolbarCallBack2', this.contactCallback);

        console.log('# PUNTO 2 #');


        Promise.all([
            loadScript(this, cttoolbar)
        ]).then(() => console.log('# javascript Loaded #'))
        .catch(error => console.log('promise error: ' + error));

        console.log('# PUNTO 3 #');

        setTimeout(() => {
            this.enableCallback();
            this.spinner = false;           
        }, 1000);

        console.log('# PUNTO 4 #');
    }

    enableCallback(){
        try{
            console.log('# bindContactCallback #');
            window.TOOLBAR.CONTACT.bindContactCallback(this.customCallback);
        } catch (err){
            console.log('## err ' + err);
        }
    }

    customCallback(jQuery_eventType, data){
        DataObj = null;

        if (typeof data === "string") {
          DataObj = JSON.parse(data);
        }

        if (typeof data === "object") {
          DataObj = data;
        }

        if (data !== null) {
            if (typeof data.event !== "undefined") {
                const selectedEvent = new CustomEvent('toolbarCallBack2');
                this.dispatchEvent(selectedEvent);
          }
        }
    }

    contactCallback = () => {
        console.log('# RICEVUTO EVENTO ' + DataObj.event);
        console.log(DataObj);

        if(DataObj && DataObj.id) {
            cacheUuid({uuid: DataObj.id})
            .then(() => {
                console.log('# UUID CACHED: ' + DataObj.id);
            });
        }

        console.log('PRIMA DI manageEvent');

        this.manageEvent();
        console.log('DOPO manageEvent');
        const toolbarEvent = new CustomEvent("toolbarevent", {
            detail: {eventType: DataObj.event, eventObj: DataObj}
        });
        this.dispatchEvent(toolbarEvent);
    };

    manageEvent(){

        console.log('MANUAL CALL : ENTRATO IN manageEVENT');
        console.log('DataObj --> '+DataObj);
        console.log('DataObj.event --> '+DataObj.event);
       
        switch (DataObj.event) {

            case 'AGENT:LOGGEDIN':
                this.agentStatus = 'standard:voice_call';
                console.log('LOGGEDIN');
                break;

            case 'AGENT:PAUSE':
                this.agentStatus = 'standard:waits';
                console.log('PAUSE');
                break;

            case 'connectionstarted':
                break;

            case 'datachanged':
                break;

            case 'serviceinitiated':
                break;

            case 'dialing':
                if(DataObj.job_type === 'manual'){
                    console.log('MANUAL DIALING ESEGUITA');
                    this.iconName = 'utility:dialing';
                    this.dialing = true;
                    this.title = 'Cliente contattato';
                }
                break;

            case 'datachanged':
                break;

            case 'established':
                if(DataObj.job_type === 'manual'){
                    console.log('MANUAL ESTABLISHED ESEGUITA');

                    //Le due linee telefoniche vengono messe in comunicazione
                    this.iconName = 'utility:incoming_call';
                    this.dialing = false;
                    console.log('ESTABLISHED!!!');

                    console.log('ESTABLISHED punto 1');
                    // this.toolbarAttributes = DataObj.event.detail.eventObj;
                    this.toolbarAttributes = DataObj;
                    console.log('ESTABLISHED punto 2');
                    console.log('ESTABLISHED punto 2.1 --> this.toolbarAttributes -> '+this.toolbarAttributes);
                    console.log('ESTABLISHED punto 2.2 --> DataObj -> '+DataObj);

                    if(this.toolbarAttributes.id) {
                        console.log('ESTABLISHED punto 3');

                        this.contactId = this.toolbarAttributes.id;
                        console.log('ESTABLISHED punto 4');
                    }

                    console.log('this.contactId --> '+this.contactId);

                    if(this.ecid != null && this.contactId != null){

                        console.log('getECID PUNTO 1');
                        window.TOOLBAR.CONTACT.SetCallData(this.contactId, this.ecid);
                        console.log('getECID PUNTO 2');

                        let phoneNum = this.phoneNumber;
                        let searchparams2 = 'filter={"filter":{"ecid":"' + this.ecid + '"},"sort":{"startTs":-1},"index":0}';
                        let searchparams = encodeURI(searchparams2);
                        let reiteklink = 'https://heraprosfdc.cloudando.com/ctreplay/externalView/search?' + searchparams;
                        this.registrationLinkVo = reiteklink;
                        console.log('*******prima di create Activity');
                        createActivity({
                            'clientNumber': String(phoneNum),
                            'registrationLink': reiteklink,
                            'ecid': this.ecid,
                            'campaignMemberId': this.recordId,
                            'agent': this.agentId
                        })
                        .then(data => {
                            console.log('*******attività creata: '+data);
                            this.activityId = data.Id;
                        })
                        .catch(error => console.error(error));

                    }
                    else{
                        console.log('### ERRORE! Numero e/o ecid non trovati ###');
                        console.log('### this.ecid --> ',this.ecid,' ###');
                        console.log('### this.contactId --> ',this.contactId,' ###');
                        const evt = new ShowToastEvent({
                            title: 'Attenzione!',
                            message: 'ContactId e/o ecid non trovati. Verificare e riprovare.',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        
                    }
                }
                break;

            case 'connectioncleared':
                if(DataObj.job_type === 'manual'){
                    this.toolbarAttributes = DataObj;

                    console.log('MANUAL CONNECTIONCLEARED ESEGUITA');
                    this.endCallDateTime = this.toolbarAttributes.endTime;
                    this.callDuration = this.toolbarAttributes.time_duration_sec != null ? (parseInt(this.toolbarAttributes.time_duration_sec) / 60).toFixed(2) : 0; // convert in minutes
                    this.waitingTime = this.toolbarAttributes.waitingTime != null ? (parseInt(this.toolbarAttributes.waitingTime) / 60).toFixed(2) : 0;
                    let ecid2=window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                    console.log('ECID2: '+ecid2);
                    this.ecid = ecid2;
                    this.sendStatus(this.ecid);
                    console.log('kkk end, duration, waiting: '+this.endCallDateTime+' '+this.callDuration+' '+this.waitingTime);
                    updateActivity({
                        ecid: this.ecid,
                        endCall: this.endCallDateTime,
                        callDuration: this.callDuration,
                        waitingTime: this.waitingTime
                    }).then(data => {
                        console.log('updateActivity --- ' + JSON.stringify(data));
                    }).catch(err => {
                        console.log(JSON.stringify(err));
                    });


                    this.iconName = 'utility:end_call';
                    this.dialing = false;
                    this.title = 'Ultimo cliente contattato';

                    setTimeout(() => {
                        this.iconName = 'utility:log_a_call';           
                    }, 2000);

                    console.log('DataObj.id --> '+DataObj.id);
                    if(DataObj.id) {
                        this.contactId = DataObj.id;
                    }

                    window.TOOLBAR.CONTACT.OfflineEnd(this.contactId);
                    console.log('OFFLINEEND DONE');
                }
                break;

            case 'DELETE':
                break;
            
            case 'POPUP':
                break;
        }
    }

    @api sendStatus(ecid) {
        getStatus({
            ecid: ecid
        }).then((response) => {
            console.log('kkk prima di savesript' + response);
            if (response != '' && response != null && response=='Appuntamento telefonico personale') {
                this.saveScript(ecid, response, true);
            }
        });
    }

    @api saveScript(ecid, esito, isResponsed) {
        let submitEcid = ecid;
        window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed).then((data) => {
            console.log('SAVESCRIPT RESULT DATA --> '+data);
            if(data){
                localStorage.removeItem("openScript-"+submitEcid);
            }
            console.log('SAVESCRIPT DONE MANUAL');
            this.saveScriptDone = true;
        });
    }

    checkEcid() {
        console.log('START getEcid');
        
        getEcid({ 'campaignMemberId': this.recordId}).then(data => {
            console.log("getEcid launch SUCCESS --> " + JSON.stringify(data));
            this.ecid = data;
            console.log('this.ecid --> '+this.ecid);
        }).catch(err => {
            console.log(err);
        });        
    }

    launchClickToCall(){

            console.log('launchClickToCall START');

            let getAgentIDPromise =  window.TOOLBAR.AGENT.getAgentID();
            let isTimeOver = false;
    
            let timeout = setTimeout(() => {
                
                console.log("Scattato il timeout della promise, verrà eseguito il codice del timeout");
                isTimeOver = true;
                const evt = new ShowToastEvent({
                    title: 'Attenzione!',
                    message: 'Non sei collegato alla barra. Verificare e ',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }, 2000);
            
            console.log('DOPO TIMEOUT');
    
            getAgentIDPromise.then((data) => {
                window.clearTimeout(timeout);
                this.agentId=data;
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
                                console.log('ARRIVATO PRIMA DI LANCIO CHECK OPEN SCRIPT');
                                if(agentState.State === 'AGENT:PAUSE'){
                                    const evt = new ShowToastEvent({
                                        title: 'Attenzione!',
                                        message: 'Per proseguire verificare che lo stato della barra sia "disponibile". ',
                                        variant: 'warning',
                                        mode: 'dismissable'
                                    });
                                    this.dispatchEvent(evt);
                                }
                                else{
                                    this.checkOpenScript();
                                }
                            }
                        }).bind(this), error => {
                            console.log('getAgentStateByID ERROR');
                            console.log(error)
                        };
                    }
                    console.log("Promise risolta, codice eseguito");
                } else {
                    isTimeOver = false
                    console.log("Promise risolta dopo il timeout, NON è stato eseguita il codice nella THEN");
                }
            }).catch(err => {
                    console.log('getAgentIDPromise ERROR');
                    console.log(err);
                });    
    }

    checkOpenScript() {
        console.log('#### START checkOpenScript ####');
        console.log('#### PUNTO 1 this.ecid --> ',this.ecid,' ####');
        
        let submitEcid = this.ecid;
        console.log('#### PUNTO 2 checkOpenScript ####');

        let openScriptNotPresent = this.checkValidityOpenScript();
        console.log('#### PUNTO 3 checkOpenScript ####');

        if(openScriptNotPresent === true){

            console.log('#### PUNTO 5 checkOpenScript ####');

            window.TOOLBAR.EASYCIM.openScript("", submitEcid, true).then((data => {
                console.log('#### PUNTO 6 checkOpenScript ####');

                console.log('## data --> '+JSON.stringify(data));
                console.log('## data.result --> '+data.result);
                console.log('## data.terminated --> '+data.terminated);
                console.log('## data.readOnly --> '+data.readOnly);

                if(data && data.result == true && data.terminated != true && data.readOnly != true){
                    console.log('data OK');
                    localStorage.setItem("openScript-"+submitEcid , Date.now());
                    // window.TOOLBAR.CONTACT.MakeCall(this.phoneNumber);
                    window.TOOLBAR.CONTACT.MakeCall(this.phoneNumber, "", "", "", "ECID="+submitEcid);
                    this.isModalOpen = false;
                }
                else{
                    console.log('#### PUNTO 10.1 ####');
                    console.log('## data.result --> '+data.result);
                    console.log('## data.terminated --> '+data.terminated);
                    console.log('## data.readOnly --> '+data.readOnly);
                    try {
                        console.log('isModalOpen --> ',this.isModalOpen);
                        this.isModalOpen = false;
                        console.log('### PUNTO 10.2 ###');
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
            console.log('openScript non eseguita perché già effettuata');
            window.TOOLBAR.CONTACT.MakeCall(this.phoneNumber, "", "", "", "ECID="+submitEcid);
            console.log('DOPO CHIAMATA');
            console.log('this.phoneNumber --> '+this.phoneNumber);
            this.isModalOpen = false;
        }
    }

    checkValidityOpenScript(){
        
        let ecidLoginTime;
        let submitEcid = this.ecid;
        console.log('checkValidityOpenScript START');
        console.log('checkValidityOpenScript submitEcid --> '+submitEcid);
        if(localStorage.getItem("openScript-"+submitEcid) != null){
            console.log('checkValidityOpenScript PUNTO 1');
            ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);
            console.log('checkValidityOpenScript PUNTO 2');
            console.log('ecidLoginTime --> '+ecidLoginTime);
            console.log('firstLoginTime --> '+this.firstLoginTime);

            if(ecidLoginTime < this.firstLoginTime){
                console.log('checkValidityOpenScript PUNTO 3');
                localStorage.removeItem("openScript-"+submitEcid);
                console.log('checkValidityOpenScript PUNTO 4');
                return true;
            }
            else{
                console.log('checkValidityOpenScript PUNTO 5');
                return false;
            }
        }
        else{
            return true;
        }
    }

    handleChange(event) {
        this.phoneNumber = event.detail.value;
        console.log(this.phoneNumber);
    }

    closeModal(){
        this.isModalOpen = false;
    }
}