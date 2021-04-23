import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOptions from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.getOptions';
import next from '@salesforce/apex/HDT_LC_ChildOrderProcessPrecheck.next';

export default class hdtChildOrderProcessPrecheck extends LightningElement {
    @api order;
    precheck = false;
    causale = '';
    causaleCompatibilita = '';
    selectedProcess = '';
    compatibilita = false;
    loaded = true;
    deliberation = '';
    showDeliberation = false;
    disabledDeliberation = false;
    showEsitoCheck = true;
    vasAmendDisabledInput = false;
    
    get value(){
        let result = '';
        console.log('**************************************** ', this.order.RecordType.DeveloperName);
        //COMMENTATO POICHE GENERAVA ERRORE
        /*if (this.order.RecordType.DeveloperName !== 'Default') {

            if(this.order.SBQQ__Quote__r.IsVAS__c){
                result = 'HDT_RT_VAS';
            } else if(this.order.SBQQ__Quote__r.AmendmentAllowed__c) {
                result = 'HDT_RT_ScontiBonus';
            } else {
                result = this.order.RecordType.DeveloperName;
            }

            this.applySelectionLogic(result);
        } else {
            result = '';
        }*/
        //COMMENTATO POICHE GENERAVA ERRORE
        return result;
    }

    get options(){

        let records = [];

        //COMMENTATO POICHE GENERAVA ERRORE
        /*if(this.order.SBQQ__Quote__r.IsVAS__c){
            records = [
                {"label":"VAS","value":"HDT_RT_VAS"}
            ]
        } else if(this.order.SBQQ__Quote__r.AmendmentAllowed__c){
            records = [
                {"label":"Aggiunta Sconti o Bonus VAS","value":"HDT_RT_ScontiBonus"}
            ]
        } else {*/
        //COMMENTATO POICHE GENERAVA ERRORE
            records = [
                {"label":"Attivazione","value":"HDT_RT_Attivazione"},
                {"label":"Attivazione con Modifica","value":"HDT_RT_AttivazioneConModifica"},
                // {"label":"Riattivazione Non Morose","value":"HDT_RT_RiattivazioniNonMorose"},
                {"label":"Subentro","value":"HDT_RT_Subentro"},
                {"label":"SwitchIn","value":"HDT_RT_SwitchIn"},
                //INIZIO SVILUPPI VOLTURA EVERIS
                {"label":"Voltura","value":"HDT_RT_Voltura"}
                //FINE SVILUPPI VOLTURA EVERIS
                // {"label":"SwitchIn con Voltura Tecnica","value":"HDT_RT_SwitchInVolturaTecnica"}
                
            ]
        //COMMENTATO POICHE GENERAVA ERRORE    
        //}
       //COMMENTATO POICHE GENERAVA ERRORE    

        return records;
    }

    handleShowDeliberation(selectedProcess){
        this.showDeliberation = (selectedProcess === 'HDT_RT_Attivazione' || selectedProcess === 'HDT_RT_RiattivazioniNonMorose');
        this.disabledDeliberation = this.order.Deliberation__c !== '';
    }

    get disabledNext(){
        let result = true;
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || (this.selectedProcess === '')){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledSave: ', result);
        return result;
    }

    get disabledInput(){
        let result = true;
        console.log('disabledInput - rcordtype', this.order.RecordType.DeveloperName);
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default' || this.vasAmendDisabledInput){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledInput: ', result);
        return result;
    }

    handleDeliberateSelection(event){
        this.deliberation = event.currentTarget.value;
    }

    applySelectionLogic(selectedProcess){
        console.log('applySelectionLogic: ', selectedProcess);

        // this.handleShowDeliberation(selectedProcess);

        if(selectedProcess === 'HDT_RT_Attivazione')
        {
            // this.precheck = false;
            // this.compatibilita = true;
            // this.causale = 'E necessario effettuare un subentro';

            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';

            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess === 'HDT_RT_RiattivazioniNonMorose'){
            this.showDeliberation = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
            this.disabledDeliberation = this.order.Step__c !== undefined;
        }
        else if(selectedProcess === 'HDT_RT_Subentro')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_SwitchIn')
        {
            // this.precheck = false;
            this.precheck = true;
            // this.compatibilita = false;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;

            this.showEsitoCheck = false;
        }
        else if(selectedProcess === 'HDT_RT_AttivazioneConModifica')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_VAS')
        {
            this.selectedProcess = 'HDT_RT_VAS';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        else if(selectedProcess === 'HDT_RT_ScontiBonus')
        {
            this.selectedProcess = 'HDT_RT_ScontiBonus';
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //INIZIO SVILUPPI EVERIS
        else if(selectedProcess === 'HDT_RT_Voltura'){
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
            this.showDeliberation = false;
        }
        //FINE SVILUPPI EVERIS 


    }

    handleSelectProcess(event){
        this.selectedProcess = event.target.value;
        this.applySelectionLogic(this.selectedProcess);
    }

    goToNextStep(extraParams){
        this.loaded = false;

        if(Object.keys(extraParams).length === 0) {
            extraParams = {};
        }

        //EVERIS
        console.log('OrderId--> '+this.order.Id);
        //EVERIS

        //EVERIS: Aggiunta variabile Order
        next({order: this.order,orderId: this.order.Id, selectedProcess: this.selectedProcess, deliberate: this.deliberation, extraParams: extraParams}).then(data =>{
            this.loaded = true;
            this.dispatchEvent(new CustomEvent('refreshorderchild'));

        }).catch(error => {
            this.loaded = true;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext(){
        console.log('handleNext: ' + this.order.Id + ' ' + this.selectedProcess);

        let extraParams = {};

        if(this.order.ServicePoint__r !== undefined){
            extraParams['servicePointType'] = this.order.ServicePoint__r.RecordType.DeveloperName;
        }

        if (this.showDeliberation === true) {
            if (this.deliberation !== '') {
                this.goToNextStep(extraParams);
            } else {
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Devi compilare il campo delibera.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            }
        } else {
            this.goToNextStep(extraParams);
        }

    }

    connectedCallback(){
        console.log('this.order: ', JSON.parse(JSON.stringify(this.order)));

        console.log('CallBack start');

        /*if(this.order.SBQQ__Quote__r.IsVAS__c || this.order.SBQQ__Quote__r.AmendmentAllowed__c){
            this.showEsitoCheck = false;
            this.vasAmendDisabledInput = true;
        }*/
        
        console.log('CallBack end');

    }
}