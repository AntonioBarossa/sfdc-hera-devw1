import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import save from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.save';
//INIZIO SVILUPPI EVERIS
import updateOrder from '@salesforce/apex/HDT_LC_SelfReading.updateOrder';
//FINE SVILUPPI EVERIS

export default class hdtChildOrderProcessActions extends LightningElement {
    @api order;
    loading = false;
    
    get disabledSave(){
        return false;
        // return (this.order.Step__c <= 2 || this.order.Step__c === undefined);
    }

    //INIZIO SVILUPPI EVERIS

    handleSaveDraft(){
        this.loading = true;

        setTimeout(result => {
            
            this.loading = false;

            this.dispatchEvent(new CustomEvent('saveevent'));

          }, 400);

        this.dispatchEvent(new CustomEvent('saveevent'));


    }
    //FINE SVILUPPI EVERIS

    handleSave(){
        this.loading = true;
        //INIZIO SVILUPPI EVERIS
        if(this.order.RecordType.DeveloperName === 'HDT_RT_Voltura'){
            
            updateOrder({recordId: this.order.Id, completed:true})
            .then(result => {

                console.log(result);

                this.loading = false; 

                this.dispatchEvent(new CustomEvent('saveevent'));

                return;

            })

        }
        //FINE SVILUPPI EVERIS
        save({order: this.order}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('saveevent'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo confermato con successo',
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
    }
}