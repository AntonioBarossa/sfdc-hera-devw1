import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTiles from '@salesforce/apex/HDT_LC_SaleServiceItemsTiles.getTiles';

export default class hdtSaleServiceItemsTiles extends LightningElement {

    @api sale;
    @track tilesData;
    showTilesInList = false;

    @api
    getTilesData(){
        getTiles({saleId:this.sale.Id}).then(data =>{
            
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

}