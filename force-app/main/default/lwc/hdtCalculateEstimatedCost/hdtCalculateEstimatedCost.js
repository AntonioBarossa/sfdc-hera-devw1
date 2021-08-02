import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOrder from '@salesforce/apex/HDT_LC_CalculateEstimatedCost.updateOrder';
import getQuoteTypeMtd from '@salesforce/apex/HDT_LC_CalculateEstimatedCost.getExtimatedCost';

export default class HdtCalculateEstimatedCost extends LightningElement {
    @track isModalOpen = false;
    @api recordId;
    @api order;

    estimateAmount;
    powerQuote;
    administrativeBurden;
    estimatedVAT;
    validityDateEstimate; //DD-MM-YYYY format
    //change date to YYYY-MM-DD format
    dateParts = this.validityDateEstimate.split("-");
    dateValue = `${this.dateParts[2]}-${this.dateParts[1]}-${this.dateParts[0]}`;
    quoteType;

    get isRapido(){
        return this.quoteType=="Rapido";
    }

    openModal() {
        // to open modal set isModalOpen track value as true
        //this.isModalOpen = true;
        this.getQuoteType()
        console.log(this.recordId);
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }

    submitDetails() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields['QuotationType__c'] = this.quoteType;
        if(this.estimateAmount!=null && this.isRapido){
            fields['EstimateAmount__c'] = this.estimateAmount;
            fields['PowerQuote__c'] = this.powerQuote;
            fields['AdministrativeBurden__c'] = this.administrativeBurden;
            fields['EstimatedVAT__c'] = this.estimatedVAT;
            fields['ValidityDateEstimate__c'] = this.dateValue;
        }
        

        console.log(JSON.stringify(fields));

        updateOrder({order: fields}).then(() => {
            this.sendToast('Success', 'Dati preventivo salvati', 'success');
        })
        .catch(error => {
            this.sendToast('Errore salvataggio preventivo',  error.body.message, 'error');
        });

        this.isModalOpen = false;
    }

    sendToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    async getQuoteType(){
        let wrapper;
        try{
            wrapper = await getQuoteTypeMtd({order:this.order});
            this.quoteType=wrapper.quoteType;
            if(this.isRapido && wrapper.estimatedAmount!=null){
                this.estimatedVAT=wrapper.fixedQuotes.VAT__c;
                this.validityDateEstimate=wrapper.validityDate;
                this.administrativeBurden=wrapper.fixedQuotes.DistributorFixedQuote__c+wrapper.fixedQuotes.SellerFixedQuote__c;
                this.powerQuote=wrapper.fixedQuotes.PowerQuote__c;
                this.estimateAmount=wrapper.estimatedAmount;
            }else{
                this.sendToast('Errore Calcolo Preventivo',  'Fallimento Nel calcolare Preventivo', 'warning');
            }
            this.isModalOpen = true;
        }catch(e){
            console.log("Exception in getQuoteType "+e);
            this.sendToast('Errore Calcolo QuoteType',  e.body.message, 'error');
        }
    }
}