import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSaleServiceItemTile from '@salesforce/apex/HDT_LC_SaleServiceContainer.createSaleServiceItemTile';
import updateSale from '@salesforce/apex/HDT_LC_SaleServiceContainer.updateSale';

export default class hdtSaleServiceContainer extends LightningElement {
    @api saleRecord;
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    servicePoint;
    currentStep = 2;
    nextStep = 3;
    loading = false;

    get hiddenEdit(){
        let result = true;
        if(this.saleRecord.CurrentStep__c <= this.currentStep){
            result = true;
        } else if(this.saleRecord.CurrentStep__c > this.currentStep){
            result = false;
        }

        return result;
    }

    get disabledNext(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledInput(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    @api
    refreshTileData(){
        this.template.querySelector('c-hdt-sale-service-items-tiles').getTilesData();
    }

    handleNewServicePoint(event){
        let newServicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: {newServicePoint}}));
    }

    handleConfirmServicePointEvent(event){
        console.log('hdtSaleServiceContainer - handleConfirmServicePointEvent: ', JSON.stringify(event.detail.newServicePoint));
        this.servicePoint = event.detail.newServicePoint;

        let oldServicePoint = {};

        if(event.detail.oldServicePoint !== undefined) {
            oldServicePoint = event.detail.oldServicePoint;
        }

        createSaleServiceItemTile({servicePoint:this.servicePoint, sale:this.saleRecord, oldServicePoint: oldServicePoint}).then(data =>{

            this.refreshTileData();
            this.dispatchEvent(new CustomEvent('newtile'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Service Point confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }

    handleTileDeleteEvent(){
        this.dispatchEvent(new CustomEvent('tiledelete'));
    }

    updateSaleRecord(saleData){
        this.loading = true;
        updateSale({sale: saleData}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext(){
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.nextStep});
    }

    handleEdit(){
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep});
    }
}