import { LightningElement, api, track} from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import cacheUuid from '@salesforce/apex/HDT_LC_CtToolbar.cacheUuid';    // params: uuid

var DataObj;

export default class HdtCtToolbar extends NavigationMixin(LightningElement) {

    @api showPanel;
    numberToCall = '';
    iconName = '';
    agentStatus = '';
    spinner = true;
    dialing = false;
    contactId;
    title = 'Scheda cliente';
    @track toolbarAttributes = [];


    connectedCallback() {
        console.log('# connectedCallback #');
        this.iconName = 'utility:log_a_call';
        this.agentStatus = 'standard:employee_contact';

        window.addEventListener('toolbarCallBack', this.contactCallback);

        Promise.all([
            loadScript(this, cttoolbar)
        ]).then(() => console.log('# javascript Loaded #'))
        .catch(error => console.log('promise error: ' + error));

        setTimeout(() => {
            this.enableCallback();
            this.spinner = false;           
        }, 1000);

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
                const selectedEvent = new CustomEvent('toolbarCallBack');
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

        this.manageEvent();
        const toolbarEvent = new CustomEvent("toolbarevent", {
            detail: {eventType: DataObj.event, eventObj: DataObj}
        });
        this.dispatchEvent(toolbarEvent);
    };

    manageEvent(){
        if (DataObj !== null) {
            if (typeof DataObj.event !== "undefined") {

                // ** Contatto Preview **
                if( (DataObj.type == 'callTask') && (DataObj.media_type == 'telephony') && (DataObj.job_type == 'previewQueue') ) {
                    if ( DataObj.event.toUpperCase() === 'POPUP') {
                      console.log('# Contatto Preview');
                      // Primo evento utile per contestualizzare il CRM. Corrisponde alla visualizzazione sulla Toolbar del POPUP di nuovo contatto in gestione.
                      // Add your custom code here....
                    }
                }

                // ** Contatto Predictive **
                if( (DataObj.type == 'callTask') && (DataObj.media_type == 'telephony') && (DataObj.job_type == 'predictive') ) {
                    if ( DataObj.event.toUpperCase() === 'POPUP') {
                      console.log('# Contatto Predictive');
                      // Primo evento utile per contestualizzare il CRM. Corrisponde alla visualizzazione sulla Toolbar del POPUP di nuovo contatto in gestione.
                      // Add your custom code here....
                    }
                }

                // ** Manual Call **
                if( (DataObj.type == 'outbound') && (DataObj.media_type == 'telephony') && (DataObj.job_type == 'manual') ) {
                    if ( DataObj.event.toUpperCase() === 'CONNECTIONSTARTED') {
                        console.log('# Manual Call');
                        // Add your custom code here....
                    }
                }
      
            }
        }  
        console.log('AUTO DataObj.job_type --> '+DataObj.job_type);

        switch (DataObj.event) {

            case 'AGENT:LOGGEDIN':
                this.agentStatus = 'standard:voice_call';
                localStorage.clear();
                break;

            case 'AGENT:PAUSE':
                this.agentStatus = 'standard:waits';
                break;

            case 'connectionstarted':
                break;

            case 'datachanged':
                break;

            case 'serviceinitiated':
                break;

            case 'dialing':
                if(DataObj.job_type !== 'manual'){
                    console.log('AUTO 2 DIALING ESEGUITA');
                    this.iconName = 'utility:dialing';
                    this.dialing = true;
                    this.title = 'Cliente contattato';
                }
                break;

            case 'datachanged':
                break;

            case 'established':
                //Le due linee telefoniche vengono messe in comunicazione
                if(DataObj.job_type !== 'manual'){
                    console.log('AUTO 2 ESTABLISHED ESEGUITA');
                    this.iconName = 'utility:incoming_call';
                    this.dialing = false;
                }
                break;

            case 'connectioncleared':
                if(DataObj.job_type !== 'manual'){
                    
                    console.log('AUTO 2 CONNECTIONCLEARED ESEGUITA');
                    
                    this.iconName = 'utility:end_call';
                    this.dialing = false;
                    this.title = 'Ultimo cliente contattato';

                    setTimeout(() => {
                        this.iconName = 'utility:log_a_call';           
                    }, 2000);


                    // console.log('DataObj.id --> '+DataObj.id);
                    // if(DataObj.id) {
                    //     this.contactId = DataObj.id;
                        
                    // }

                    // window.TOOLBAR.CONTACT.OfflineEnd(this.contactId);
                    // console.log('OFFLINEEND DONE');
                }
                break;

            case 'DELETE':
                break;
                
        }
    }

    setNumber(event){
        this.numberToCall = event.target.value;
    }

    @api callNumberFromParent(numToCall){
        this.numberToCall = numToCall;
        this.callThisNumber();
    }

    callThisNumber(){
        console.log('## callThisNumber #');
        try{
            if(this.numberToCall != '' && this.numberToCall != undefined){
                this.iconName = 'utility:outbound_call';
                window.TOOLBAR.CONTACT.MakeCall(this.numberToCall);
            } else {
                console.log('## no number found #');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione!',
                        message: 'Non hai inserito nessun numero.',
                        variant: 'warning'
                    })
                );
            }
        } catch (err){
            console.log('## err ' + err);
        }
    }

    @api hangUpFromParent(){
        this.hangup();
        this.numberToCall = '';
    }

    hangup(){
        console.log('## Hangup #');
        window.TOOLBAR.CONTACT.Hangup();
        this.iconName = 'utility:end_call';
        this.dialing = false;
        
        setTimeout(() => {
            this.iconName = 'utility:log_a_call';           
        }, 2000);

    }
    
}