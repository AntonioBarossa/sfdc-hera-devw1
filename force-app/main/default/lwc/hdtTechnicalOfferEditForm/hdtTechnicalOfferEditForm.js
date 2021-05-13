import { LightningElement, api } from 'lwc';

export default class HdtTechnicalOfferEditForm extends LightningElement {
    @api productId;
    technicalOfferId = '';
    fieldsList = [
        'Market__c',
        'ProcessType__c',
        'PlacetOffer__c',
        'ServiceProduct__c',
        'StepAllowed__c',
        'StartDate__c',
        'EndDate__c',
        'ContractId__c',
        'NumberTimeExtension__c',
        'UnitTimeExtension__c',
        'CancellationAllowed__c',
        'NunmberDaysMonthsYears__c',
        'UnitTerminationTime__c',
        'RecessAdmitted__c',
        'NumberOfTimeUnits__c',
        'UnitOfTimeMeasurement__c',
        'AdmittingProfileModification__c',
        'OfferToBeModified__c'
      ];

    handleLoad(event){
        console.log('>>>> handleLoad ');
    }

    handleSuccess(event) {
        console.log('>>>> handleSuccess ' + event.detail.id);

        const newOffer = new CustomEvent('newoffercreated', {
            detail: {newTechOfferId: event.detail.id}
        });
        // Fire the custom event
        this.dispatchEvent(newOffer);       
    }

    handleError(event){
        console.log('>>>> handleErrore ');
        console.log('>>>> ' + event.detail.message);
        console.log(JSON.stringify(event.detail.output.fieldErrors));
    }

    handleSubmit(event){
        console.log('>>>> handleSubmit ');
        //event.preventDefault();       // stop the form from submitting
        //const fields = event.detail.fields;
        //fields.Street = '32 Prince Street';
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    saveAction(){
        console.log('>>>> saveAction ');
        const fields = this.template.querySelectorAll('lightning-input-field');
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    closeModal(event){
        const closemodal = new CustomEvent('closemodal', {
            detail: ''
        });
        // Fire the custom event
        this.dispatchEvent(closemodal);
    }

}