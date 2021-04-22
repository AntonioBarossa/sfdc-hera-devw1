import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
//import cttoolbar from '@salesforce/resourceUrl/agentdesktop_widget';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';

var DataObj;

export default class HdtCtToolbar extends NavigationMixin(LightningElement) {
    numberToCall = '';
    iconName = '';
    agentStatus = '';
    spinner = true;
    dialing = false;
    recordid;
    title = 'Scheda cliente';

    renderedCallback(){
        //window.addEventListener('dialing', this.myFunction);
    }

    connectedCallback() {
        console.log('# connectedCallback #');
        this.iconName = 'utility:log_a_call';
        this.agentStatus = 'standard:employee_contact';

        window.addEventListener('toolbarCallBack', this.contactCallback);

        Promise.all([
            loadScript(this, cttoolbar)//, loadScript(this, socket)
        ]).then(() => console.log('# javascript Loaded #'))
        .catch(error => console.log('promise error: ' + error));

        setTimeout(() => {
            this.enableCallback();
            this.spinner = false;           
        }, 1000);

    }

    contactCallback = () => {
        console.log('# RICEVUTO EVENTO ' + DataObj.event + ' #');
        //console.log('# media_type: ' + DataObj.media_type + '; type: ' + DataObj.type + '; job_type: ' + DataObj.job_type);

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


        switch (DataObj.event) {

            case 'AGENT:LOGGEDIN':
                this.agentStatus = 'standard:voice_call';
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
                this.iconName = 'utility:dialing';
                this.dialing = true;
                this.recordid = '0015I000003e4w3QAA';
                this.title = 'Cliente contattato';


                //this[NavigationMixin.Navigate](
                //    {
                //        type: 'comm__namedPage',
                //        attributes: {
                //            name: 'ct-phone-7'
                //        }
                //    }
                //);

                break;

            case 'datachanged':
                break;

            case 'established':
                //Le due linee telefoniche vengono messe in comunicazione
                this.iconName = 'utility:incoming_call';
                this.dialing = false;
                break;

            case 'connectioncleared':
                this.iconName = 'utility:end_call';
                this.dialing = false;
                this.title = 'Ultimo cliente contattato';

                setTimeout(() => {
                    this.iconName = 'utility:log_a_call';           
                }, 2000);

                break;

            case 'DELETE':
                
        }

    };

    enableCallback(){
        try{
            console.log('# bindContactCallback #');
            window.TOOLBAR.CONTACT.bindContactCallback(this.customCallback);
        } catch (err){
            console.log('## err ' + err);
        }
    }

    setNumber(event){
        //var fieldId = event.target.id;
        this.numberToCall = event.target.value;
    }

    callThisNumber(event){
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

    hangup(event){
        console.log('## Hangup #');
        window.TOOLBAR.CONTACT.Hangup();
        this.iconName = 'utility:end_call';
        this.dialing = false;
        
        setTimeout(() => {
            this.iconName = 'utility:log_a_call';           
        }, 2000);

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
            //console.log('# ' + JSON.stringify(data));
            if (typeof data.event !== "undefined") {
                //DataObj = data;
                //const selectedEvent = new CustomEvent('toolbarCallBack', { detail: data.event });
                const selectedEvent = new CustomEvent('toolbarCallBack');
                this.dispatchEvent(selectedEvent);
          }
        }

    }

}