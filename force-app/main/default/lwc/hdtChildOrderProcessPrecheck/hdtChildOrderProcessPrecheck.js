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
    
    get value(){
        let result = '';
        if (this.order.RecordType.DeveloperName !== 'Default') {
            result = this.order.RecordType.DeveloperName;
            this.applySelectionLogic(this.order.RecordType.DeveloperName);
        } else {
            result = '';
        }
        return result;
    }

    get options(){
        return [
            {"label":"Attivazione","value":"HDT_RT_Attivazione"},
            {"label":"Attivazione con Modifica","value":"HDT_RT_AttivazioneConModifica"},
            {"label":"Riattivazione Non Morose","value":"HDT_RT_RiattivazioniNonMorose"},
            {"label":"Subentro","value":"HDT_RT_Subentro"},
            {"label":"SwitchIn","value":"HDT_RT_SwitchIn"},
            {"label":"SwitchIn con Voltura Tecnica","value":"HDT_RT_SwitchInVolturaTecnica"}
        ];
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
        if(this.order.RecordType.DeveloperName !== 'HDT_RT_Default'){
            result = true;
        } else {
            result = false;
        }
        console.log('disabledInput: ', result);
        return result;
    }

    applySelectionLogic(selectedProcess){
        console.log('applySelectionLogic: ', selectedProcess);
        if(selectedProcess === 'HDT_RT_Attivazione')
        {
            this.precheck = false;
            this.compatibilita = true;
            this.causale = 'E necessario effettuare un subentro';
        }
        else if(selectedProcess === 'HDT_RT_Subentro')
        {
            this.precheck = true;
            this.compatibilita = true;
            this.causale = '';
        }
    }

    handleSelectProcess(event){
        this.selectedProcess = event.target.value;
        this.applySelectionLogic(this.selectedProcess);
    }

    handleNext(){
        this.loaded = false;
        next({orderId: this.order.Id, selectedProcess: this.selectedProcess}).then(data =>{
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

    connectedCallback(){
        console.log('this.order: ', JSON.parse(JSON.stringify(this.order)));
    }
}