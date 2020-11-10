import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTiles from '@salesforce/apex/HDT_LC_SaleServiceItemsTiles.getTiles';
import deleteTile from '@salesforce/apex/HDT_LC_SaleServiceItemsTiles.deleteTile';

export default class hdtSaleServiceItemsTiles extends LightningElement {

    @api sale;
    @track tilesData;
    showTilesInList = false;
    loaded = false;
    isDialogVisible = false;
    opportunityToDeleteId;
    opportunityToDeleteName;
    dialogTitle;
    dialogMessage;

    @api
    getTilesData(){
        getTiles({saleId:this.sale.Id}).then(data =>{

            this.loaded = true;

            let tilesArray = [];

            data.forEach(el => {
                tilesArray.push({
                    "Id"           :el[0].Opportunity__c,
                    "Name"         :el[0].Opportunity__r.Name,
                    "Type"         :el[0].ServicePoint__r.RecordType.Name,
                    "City"         :el[0].ServicePoint__r.SupplyCity__c,
                    "ServicePoints":el
                });
            });
            
            this.tilesData = tilesArray;

            this.showTilesInList = data.length > 4 ? true : false;

        }).catch(error => {
            this.loaded = true;
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    connectedCallback(){
        this.getTilesData();
    }

    handleTileDelete(event){
        this.opportunityToDeleteId = event.currentTarget.dataset.id;
        this.opportunityToDeleteName = event.currentTarget.dataset.name;
        this.dialogTitle = 'Cancella '+ this.opportunityToDeleteName;
        this.dialogMessage = 'Vuoi cancellare ' + this.opportunityToDeleteName + ' ?';
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){
            this.loaded = false;
            deleteTile({opportunityId:this.opportunityToDeleteId}).then(data =>{
                this.loaded = true;
    
                this.getTilesData();
                
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Opportunity cancellata con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastErrorMessage);
    
            }).catch(error => {
                this.loaded = true;
                console.log(error.message);
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        } else {
            this.isDialogVisible = false;
        }
    }

}