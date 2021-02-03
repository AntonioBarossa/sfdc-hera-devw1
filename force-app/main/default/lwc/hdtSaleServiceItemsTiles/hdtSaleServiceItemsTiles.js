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
        this.loaded = false;
        getTiles({saleId:this.sale.Id}).then(data =>{

            this.loaded = true;

            let tilesArray = [];

            data.saleServiceItemsTiles.forEach(el => {
                tilesArray.push({
                    "Id"           :el[0].Opportunity__c,
                    "Name"         :el[0].Opportunity__r.Name,
                    "Type"         :el[0].ServicePoint__r.RecordType.Name,
                    "City"         :el[0].ServicePoint__r.SupplyCity__c,
                    "ServicePoints":el,
                    "CreatedDate": el[0].Opportunity__r.CreatedDate
                });
            });

            data.vasTiles[0].forEach(el => {

                let vasType = '';
                let vasEl = {Id: '', Number: ''};
                if (el.SBQQ__PrimaryQuote__r.OrderReference__c !== undefined) {
                    vasType = 'Order VAS';
                    vasEl = {Id: el.SBQQ__PrimaryQuote__r.OrderReference__c, Number: el.SBQQ__PrimaryQuote__r.OrderReference__r.OrderNumber};
                } else if (el.SBQQ__PrimaryQuote__r.ContractReference__c !== undefined) {
                    vasType = 'Contract VAS';
                    vasEl = {Id:el.SBQQ__PrimaryQuote__r.ContractReference__c, Number:el.SBQQ__PrimaryQuote__r.ContractReference__r.ContractNumber};
                } else {
                    vasType = 'Vas Stand Alone';
                }

                tilesArray.push({
                    "Id"           :el.Id,
                    "Name"         :el.Name,
                    "Type"         :vasType,
                    "City"         :el.SBQQ__PrimaryQuote__r.SupplyCity__c,
                    "VasEl"        :vasEl,
                    "CreatedDate"  :el.CreatedDate
                });
            });
            
            this.tilesData = tilesArray;

            this.tilesData = this.tilesData.sort((a, b) => (a.CreatedDate > b.CreatedDate) ? 1 : -1);

            this.showTilesInList = this.tilesData.length > 4 ? true : false;

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
                
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Opportunity cancellata con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
                this.dispatchEvent(new CustomEvent('tiledelete'));
    
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