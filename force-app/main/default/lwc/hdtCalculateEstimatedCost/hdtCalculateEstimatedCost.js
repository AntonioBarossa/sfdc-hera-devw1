import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOrder from '@salesforce/apex/HDT_LC_CalculateEstimatedCost.updateOrder';

export default class HdtCalculateEstimatedCost extends LightningElement {
    @track isModalOpen = false;
    @api recordId;

    estimateAmount = "500";
    powerQuote = "100";
    administrativeBurden = "50";
    estimatedVAT = "10";
    validityDateEstimate = "18-05-2021"; //DD-MM-YYYY format
    //change date to YYYY-MM-DD format
    dateParts = this.validityDateEstimate.split("-");
    dateValue = `${this.dateParts[2]}-${this.dateParts[1]}-${this.dateParts[0]}`;

    openModal() {
        // to open modal set isModalOpen track value as true
        this.isModalOpen = true;
        console.log(this.recordId);
    }

    closeModal() {
        // to close modal set isModalOpen track value as false
        this.isModalOpen = false;
    }

    submitDetails() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields['EstimateAmount__c'] = this.estimateAmount;
        fields['PowerQuote__c'] = this.powerQuote;
        fields['AdministrativeBurden__c'] = this.administrativeBurden;
        fields['EstimatedVAT__c'] = this.estimatedVAT;
        fields['ValidityDateEstimate__c'] = this.dateValue;

        console.log(JSON.stringify(fields));

        updateOrder({order: fields}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Dati preventivo salvati',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore salvataggio preventivo',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });

        this.isModalOpen = false;
    }
}