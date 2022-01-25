import { LightningElement,wire, track,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getDecryptedId from '@salesforce/apex/HDT_LC_AppointmentAgenda.getDecryptedId';

const FIELDS_TO_RETRIEVE = [
    'wrts_prcgvr__Status__c',
    'FiscalCode__c',
    'VATNumber__c'

];

export default class HdtAppointmentCommunity extends LightningElement {
    @api privacyUrl = '';
    isCommunity = false;
    recordId = '';
    showAgenda = false;
    showLogin = false;
    showError = false;
    showSpinner = true;
    message = '';
    activity = {};
    @track robotClass= 'slds-checkbox-button';
    @track privacy = false;
    @track iAmRobot = true;
    @track disabledPrivacy = true;

    get disabledButton(){
        return this.iAmRobot || !this.privacy;
    } 
    
    get showPrivacy(){
        return !(this.privacyUrl === '' || this.privacyUrl === undefined || this.privacyUrl === null) ;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state.c__activityId) {
            this.isCommunity = true;
            let activityId = localStorage.getItem('activityId');
            if (this.privacyUrl === '' || this.privacyUrl === undefined || this.privacyUrl === null){
                this.privacy = true;
            }
            if (activityId){
                console.log('gestione autenticato');
                this.recordId = activityId;
                this.setShowItem(false,true,false,false);
            }else{
                console.log('gestione da autenticare');
                this.setShowItem(true,false,false,false);
                getDecryptedId({
                    cryptedId : currentPageReference.state.c__activityId,
                    fields : FIELDS_TO_RETRIEVE
                }).then((data) => {
                    console.log('@@@@data '+ data);
                    if (data != ''){
                        this.activity = JSON.parse(data);
                        this.recordId = this.activity.Id;
                        this.setShowItem(false,false,true,false);
                    }else{
                        this.message = 'Attenzione! Non è stato trovato nessun appuntamento';
                        this.setShowItem(false,false,false,true);
                    }
                }).catch((error) => {
                    this.message = JSON.stringify(error.body.message);
                    this.setShowItem(false,false,false,true);
                })
            }
        }else{
            this.message = 'Attenzione! Non è stato trovato nessun appuntamento';
            this.setShowItem(false,false,false,true);
        }
    }

    setShowItem(spinner,agenda,login,error){
        this.showAgenda = agenda;
        this.showSpinner = spinner;
        this.showLogin = login;
        this.showError = error;
    }

    handleAuthenticate(event){
        let userData = this.template.querySelector("[data-id='userData']").value;
        if (this.validateInput(userData)){
            localStorage.setItem('activityId',this.recordId);
            this.setShowItem(false,true,false,false);
        }
    }

    handlePrivacy(event){
       this.privacy = !this.privacy;
    }

    validateInput(value){
        console.log('@@@@value ' + value);
        let valueForCheck ={cf : '', pi : ''};
        console.log('@@@@activity ' + JSON.stringify(this.activity));
        let response = false;
        if (value){
            response = true;
            if (this.activity.FiscalCode__c){
                console.log('@@@@get cf from activity');
                valueForCheck.cf=this.activity.FiscalCode__c;
            }
    
            if (this.activity.VATNumber__c){
                console.log('@@@@get pi from activity');
                valueForCheck.pi=this.activity.VATNumber__c;
            }
    
            console.log('@@@@ValueForCheck ' + JSON.stringify(valueForCheck));
            if((valueForCheck.cf === '' && valueForCheck.pi ==='') || (value != valueForCheck.cf && value != valueForCheck.pi)){
                response = false;
                alert('Attenzione! Partita Iva o Codice Fiscale non valido.');
            }
        }else{
            alert('Attenzione! Il campo codice fiscale o Partita Iva è obbligatorio.');
        }
         
        return response;
    }

    changeRobotState(event){
        console.log('@@@@@changeRobotState');
        this.iAmRobot = !this.iAmRobot;
        if (this.iAmRobot){
            this.robotClass='slds-checkbox-button';
        }else{
            this.robotClass='slds-checkbox-button slds-checkbox-button_is-checked';
        }
    }

    enablePrivacy(event){
        this.disabledPrivacy = false;
    }

}