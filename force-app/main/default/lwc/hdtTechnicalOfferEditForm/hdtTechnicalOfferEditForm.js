import { LightningElement, api } from 'lwc';

export default class HdtTechnicalOfferEditForm extends LightningElement {
    @api productId;
    technicalOfferId = '';
    techOffId;
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
    }

    saveAction(){
        console.log('>>>> saveAction ');
        var techOffObj = {};
        const fields = this.template.querySelectorAll('lightning-input-field');
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            techOffObj[field.fieldName] = field.value;
        });

        const newOffer = new CustomEvent('newoffercreated', {
            detail: {newTechOfferObj: JSON.stringify(techOffObj)}
        });
        // Fire the custom event
        this.dispatchEvent(newOffer);

    }

    closeModal(event){
        const closemodal = new CustomEvent('closemodal', {
            detail: ''
        });
        // Fire the custom event
        this.dispatchEvent(closemodal);
    }

}