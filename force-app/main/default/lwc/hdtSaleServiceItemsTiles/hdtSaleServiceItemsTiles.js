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

            console.log(JSON.parse(JSON.stringify(data)));
            
            this.tilesData = data;

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