import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.save';
import saveDraft from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.saveDraft';
import cancel from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.cancel';
import calculateRate from '@salesforce/apex/HDT_UTL_Order.calculateRateCategory';
export default class hdtChildOrderProcessActions extends LightningElement {
    @api order;
    @api lastStepNumber;
    @api draftObject;
    @api draftObjectApiName;
    @api diffDraftObjectApiName;
    @api diffFields;
    @api lastStepData;
    loading = false;
    isDialogVisible = false;

    get notBillableVas(){
        return this.order.RecordType.DeveloperName !== 'HDT_RT_VAS' || !this.order.IsBillableVas__c;
    }
    
    get cancellationOptions() {
        return [
            { label: 'Pratica errata', value: 'Pratica errata' },
            { label: 'Annullamento da cliente', value: 'Annullamento da cliente' },
            { label: 'Processo incompatibile', value: 'Processo incompatibile' }
        ];
    }
    
    get disabledSave(){
        //INIZIO SVILUPPI EVERIS

        /*if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){

            console.log(this.lastStepNumber);

            return !(this.lastStepNumber === 1);

        }*/

        //FINE SVILUPPI EVERIS

        console.log('lastStepNumber disabledSave: ', this.lastStepNumber);
        console.log('this.order.Step__c disabledSave: ', this.order.Step__c);
        return (this.order.Step__c !== this.lastStepNumber && ( this.order.RecordType.DeveloperName !== 'HDT_RT_ScontiBonus' && this.notBillableVas ));
    }

    dateWithMonthsDelay (months) {
        const date = new Date();
        date.setMonth(date.getMonth() + months);

        return date;
    }

    dateCompare(d1, d2){

        let result = '';

        if(d1 > d2){
            result = 'greater';
        } else if(d1 < d2){
            result = 'lower';
        } else{
            result = 'equal';
        }

        return result;
    }

    validateLastStepFields(lastStepFields){

        let result = true;

        if (lastStepFields.IsActivationDeferred__c !== undefined && lastStepFields.IsActivationDeferred__c) {

            if (lastStepFields.EffectiveDate__c !== undefined) {
                let effectiveDateInput = new Date(lastStepFields.EffectiveDate__c);
                let dateToCompare1 = this.dateWithMonthsDelay(1);

                if (this.dateCompare(effectiveDateInput, dateToCompare1) === 'lower' || effectiveDateInput.getDate() !== 1) {
                    this.loading = false;
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Data decorrenza non valida!',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(toastErrorMessage);
                    result = false;
                }
            }

        }

        return result;

    }

    handleSave(){
        this.loading = true;

        let orderToSave = {};

        console.log('keltin this.lastStepData: ' + JSON.stringify(this.lastStepData));

        if (this.lastStepData != null) {

            if (!this.validateLastStepFields(this.lastStepData)) {
                return;
            }

        } 
        
        orderToSave = this.order;

        calculateRate({ord: orderToSave}).then(data2 =>{
            if(!data2){
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Non è stato possibile calcolare la RateCategory',
                    variant: 'warning'
                });
                this.dispatchEvent(toastSuccessMessage);
            }

        save({order: orderToSave, lastStepData: this.lastStepData}).then(data =>{
            this.loading = false;

            if(this.order.ProcessType__c === 'Switch in Ripristinatorio' || this.order.IsCloned__c===true){
                console.log('redirect_attivazione_mod');
                this.dispatchEvent(new CustomEvent('redirect_attivazione_mod'));
            } else {
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
            }

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
        });
    }

    handleSaveDraft(){
        // console.log('handleSaveDraft: ' + this.draftObjectApiName + ' ' + JSON.stringify(this.draftObject));
        console.log('handleSaveDraft: ' + this.draftObjectApiName);
        console.log('handleSaveDraft: ' + JSON.stringify(this.draftObject));
        console.log('handleSaveDraft Diff: ' + this.diffDraftObjectApiName + ' ' + JSON.stringify(this.diffFields));
        
        if ( this.draftObject != null && this.diffFields == null) {

            this.loading = true;
            saveDraft({objectApiName: this.draftObjectApiName, objectToUpdate: this.draftObject}).then(data =>{
                this.loading = false;
    
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
    
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Processo salvato in bozza',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    
            }).catch(error => {
                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else if( this.diffFields != null && this.draftObject == null ) {

            this.loading = true;
            saveDraft({objectApiName:this.diffDraftObjectApiName, objectToUpdate: this.diffFields}).then(data =>{
                this.loading = false;
    
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
    
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Processo salvato in bozza',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    
            }).catch(error => {
                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else if(this.draftObject != null && this.diffFields != null){

            this.loading = true;
            saveDraft({
                objectApiName: this.draftObjectApiName,
                objectToUpdate: this.draftObject,
                diffObjectApiName: this.diffDraftObjectApiName,
                diffObjectToUpdate: this.diffFields

                }).then(data =>{
                this.loading = false;
    
                this.dispatchEvent(new CustomEvent('redirecttoparent'));
    
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Processo salvato in bozza',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    
            }).catch(error => {
                this.loading = false;
                console.log((error.body.message !== undefined) ? error.body.message : error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: (error.body.message !== undefined) ? error.body.message : error.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            });

        } else {
            console.log('hdtChildOrderProcessActions - handleSaveDraft - draftObject has no data');
            this.dispatchEvent(new CustomEvent('redirecttoparent'));
        }
    }

    callCancel(cancellationReason){
        this.loading = true;
        cancel({order: this.order, cancellationReason: cancellationReason}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoparent'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo annullato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleCancel(){
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){

            this.callCancel(event.detail.choice);

        } else {
            this.isDialogVisible = false;
        }
    }
}