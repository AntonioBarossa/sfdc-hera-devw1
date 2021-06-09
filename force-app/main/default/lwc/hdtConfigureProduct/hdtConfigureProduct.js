import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/HDT_LC_ConfigureProduct.getQuotes';
import cancelQuote from '@salesforce/apex/HDT_LC_ConfigureProduct.cancelQuote';
import updateSaleNext from '@salesforce/apex/HDT_LC_ConfigureProduct.updateSaleNext';
import updateSalePrevious from '@salesforce/apex/HDT_LC_ConfigureProduct.updateSalePrevious';
import amendContract from '@salesforce/apex/HDT_LC_ConfigureProduct.amendContract';

export default class hdtConfigureProduct extends LightningElement {
    
    @api saleRecord;
    @api isCommunity;
    quotesData;
    loaded = false;
    showEditQuote = false;
    selectedQuoteId;
    selectedContractId = '';
    cancelQuoteId;
    cancelQuoteOpportunityId;
    dialogTitle;
    dialogMessage;
    isDialogVisible = false;
    currentStep = 3;
    nextStep = 4;
    showAmend = false;
    iframeSrcAmend = '';

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

    get disabledButton(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    @api
    getQuotesData(isCancelActionCheck = false){
        this.loaded = false;
        getQuotes({saleId: this.saleRecord.Id}).then(data =>{
            this.loaded = true;

            let quotesArray = [];
            let count = 0;

            data.forEach(el => {
                quotesArray.push({
                    "Count"                :++count,
                    "Id"                   :el.quote[0].Id,
                    "Name"                 :el.quote[0].Name,
                    "Type"                 :el.quote[0].SBQQ__Type__c,
                    "OpportunityName"      :el.quote[0].SBQQ__Opportunity2__r.Name,
                    "OpportunityId"        :el.quote[0].SBQQ__Opportunity2__r.Id,
                    "AmendmentAllowed"     :el.quote[0].AmendmentAllowed__c !== undefined && el.quote[0].AmendmentAllowed__c && el.quote[0].SBQQ__Type__c === 'Quote' ? true : false,
                    "ContractReference"    :el.quote[0].ContractReference__c !== undefined ? el.quote[0].ContractReference__c : '',
                    "QuoteLines"           :el.quoteLines
                });
            });

            this.quotesData = quotesArray;

            if (isCancelActionCheck) {
                if (this.quotesData.length === 0) {
                    this.updateSaleRecordPrevious({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep - 1});
                }
            }

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
        this.getQuotesData();
    }

    handleOpenConfigureModal(event){
        this.selectedQuoteId = event.currentTarget.dataset.id;
        this.showEditQuote = true;
    }

    handleCloseEditQuoteEvent(){
        this.showEditQuote = false;
    }

    handleAmend(event){
        this.selectedContractId = event.currentTarget.dataset.id;
        // this.selectedContractId = '8007Y000002vCnkQAE'; //used for testing
        console.log('this.selectedContractId: ', this.selectedContractId);
        //'/apex/sbqq__sb?scontrolCaching=1&amp;id=' + quoteId +'#quote/le?qId='+ quoteId;
        // this.iframeSrcAmend = '/apex/sbqq__AmendContract?id=8007Y000002vCnkQAE';
        this.showAmend = true;

        // this.loaded = false;
        // amendContract({contractId: this.selectedContractId}).then(data =>{
        //     this.loaded = true;

        //     console.log('amendContract: ', JSON.stringify(data));

        // }).catch(error => {
        //     this.loaded = true;
        //     const toastErrorMessage = new ShowToastEvent({
        //         title: 'Errore',
        //         message: error.message,
        //         variant: 'error'
        //     });
        //     this.dispatchEvent(toastErrorMessage);
        // });

    }

    handleCloseAmendContract(){
        this.showAmend = false;
        this.dispatchEvent(new CustomEvent('refresh_tiles'));
    }

    handleQuoteDelete(event){
        this.cancelQuoteId = event.currentTarget.dataset.id;
        this.cancelQuoteOpportunityId = event.currentTarget.dataset.opportunityid;
        console.log('this.cancelQuoteId: ', this.cancelQuoteId);
        console.log('this.cancelQuoteOpportunityId: ', this.cancelQuoteOpportunityId);
        let quoteName = event.currentTarget.dataset.name;
        this.dialogTitle = "Cancella la Quote " + quoteName;
        this.dialogMessage = "Scegli una causale per procedere: ";
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){
            this.loaded = false;
            cancelQuote({
                quoteId:this.cancelQuoteId,
                opportunityId:this.cancelQuoteOpportunityId,
                cancellationReason:event.detail.choice
                }).then(data =>{
                this.loaded = true;
    
                this.getQuotesData(true);
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Quote eliminata con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
                this.dispatchEvent(new CustomEvent('quotecancel'));
    
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

    handleCreatedQuoteLinesEvent(){
        this.getQuotesData();
    }

    updateSaleRecordNext(saleData){
        this.loaded = false;
        updateSaleNext({sale: saleData}).then(data =>{
            this.loaded = true;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
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

    updateSaleRecordPrevious(saleData){
        this.loaded = false;
        updateSalePrevious({sale: saleData}).then(data =>{
            this.loaded = true;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
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
        this.updateSaleRecordNext({Id: this.saleRecord.Id, CurrentStep__c: this.nextStep});
    }

    handleEdit(){
        this.updateSaleRecordPrevious({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep});
    }
}