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
    get administrativeBurdenDisplay(){
        return this.administrativeBurden.toFixed(2);
    }
    estimatedVAT;
    validityDateEstimate; //DD-MM-YYYY format
    //change date to YYYY-MM-DD format

    get dateParts(){
        if(this.validityDateEstimate!=null){
            return this.validityDateEstimate.split("-");
        }
        else{
            return;
        } 
    }

    get dateValue(){
        if(this.dateParts){
            return `${this.dateParts[2]}-${this.dateParts[1]}-${this.dateParts[0]}`;
        }else{
            return;
        }
    }

    quoteType;
    operationCode;

    get isRapido(){
        return this.quoteType=="Rapido";
    }

    openModal() {
        // to open modal set isModalOpen track value as true
        //this.isModalOpen = true;
        console.log('#Order >>>' +JSON.stringify(this.order));
        this.dispatchEvent(new CustomEvent('calculatecost',{detail: ''}));
        /*this.getQuoteType();
        console.log(this.recordId);*/
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }

    submitDetails() {
        if(!this.quoteType){
            this.isModalOpen = false;
            return;
        }
        const fields = {};
        fields['Id'] = this.recordId;
        fields['QuotationType__c'] = this.quoteType;
        fields['OperationCode__c'] = this.operationCode;
        if(this.estimateAmount!=null && this.isRapido){
            fields['EstimateAmount__c'] = this.estimateAmount;
            fields['PowerQuote__c'] = this.powerQuote;
            fields['AdministrativeBurden__c'] = this.administrativeBurden;
            fields['EstimatedVAT__c'] = this.estimatedVAT;
            fields['ValidityDateEstimate__c'] = this.dateValue;
        }
        

        console.log(JSON.stringify(fields));

        updateOrder({order: fields}).then(() => {
            if(this.isRapido)
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

    @api
    async getQuoteType(){
        let wrapper;
        console.log('#OrderFilledWithNewMethod >>> ' + JSON.stringify(this.order));
        try{
            wrapper = await getQuoteTypeMtd({ord:this.order});
            this.operationCode=wrapper.quoteCode;
            this.quoteType=wrapper.quoteType;
            console.log(wrapper.quoteType);
            console.log(this.quoteType);
            if(this.isRapido && wrapper.estimatedAmount!=null){
                this.estimatedVAT=wrapper.fixedQuotes.VAT__c;
                this.validityDateEstimate=wrapper.validityDate;
                this.administrativeBurden=wrapper.fixedQuotes.DistributorFixedQuote__c+wrapper.fixedQuotes.SellerFixedQuote__c;
                this.powerQuote=wrapper.fixedQuotes.PowerQuote__c;
                this.estimateAmount=wrapper.estimatedAmount;
            }else{
                this.sendToast('Errore Calcolo Preventivo',  'Non è possibile calcolare il preventivo in questa fase, sarà calcolata nelle fasi successive', 'warning');
            }
            this.isModalOpen = true;
        }catch(e){
            console.log("Exception in getQuoteType "+e);
            this.sendToast('Errore Calcolo QuoteType',  e.body.message, 'error');
        }
    }
}