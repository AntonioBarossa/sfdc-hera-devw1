import { LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class HdtTechnicalOfferEditForm extends LightningElement {

    @api productId;
    @api rateObj;
    fieldsList = [
        'Market__c',
        'ProcessType__c',
        'PlacetOffer__c',
        //'ServiceProduct__c',
        'StartDate__c',
        'EndDate__c',
        'StepAllowed__c',
        'ContractId__c',
        'NumberTimeExtension__c',
        'UnitTimeExtension__c',
        'CancellationAllowed__c',
        'NumberDaysMonthsYears__c',
        'UnitTerminationTime__c',
        'RecessAdmitted__c',
        'NumberOfTimeUnits__c',
        'UnitOfTimeMeasurement__c',
        'AdmittingProfileModification__c',
        'OfferToBeModified__c'
    ];

    @api mode;
    @api technicalOfferId;
    hidden = 'slds-show';

    @api handleValueChange() {
        console.log('>>> handleValueChange');
        if(this.hidden === 'slds-show'){
            this.hidden='slds-hide';
        } else {
            this.hidden = 'slds-show';
        }
    }

    connectedCallback(){
        console.log('>>> connectedCallback HdtTechnicalOfferEditForm');
    }

    handleLoad(event){
        console.log('>>>> handleLoad ');
    }

    handleSuccess(event) {
        console.log('>>>> handleSuccess ' + event.detail.id);
    }

    handleError(event){
        console.log('>>>> handleErrore ');
        console.log('>>>> ' + event.detail.message);
        console.log(JSON.stringify(event.detail.output.fieldErrors));
    }

    handleSubmit(event){
        console.log('>>>> handleSubmit ');
        event.preventDefault();
    }

    saveAction(){
        console.log('>>>> saveAction ');
        var techOffObj = {};

        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            console.log('>>> ' + field.fieldName + ' - ' + field.value);
            techOffObj[field.fieldName] = field.value;
        });

        this.hidden = 'slds-hide';

        const newOffer = new CustomEvent('newoffercreated', {
            detail: {newTechOfferObj: JSON.stringify(techOffObj)}
        });
        // Fire the custom event
        this.dispatchEvent(newOffer);

    }

    closeModal(event){
        var closeMode = '';

        if(this.mode === 'edit'){
            closeMode = 'closeedit';
        } else if(this.mode === 'insert'){
            closeMode = 'closemodal';
        }

        const closemodal = new CustomEvent(closeMode, {
            detail: ''
        });
        // Fire the custom event
        this.dispatchEvent(closemodal);
    }

    checkValue(techOffObj){
        console.log('>>> checkValue ');

        var returnObj = {
            success: false,
            message: ''
        };

        if(this.checkIsNotNull(techOffObj.StartDate__c) && this.checkIsNotNull(techOffObj.EndDate__c)){
           
            var start = new Date(techOffObj.StartDate__c);
            var end = new Date(techOffObj.EndDate__c);

            if(start >= end){
                returnObj.message = 'Data fine inferiore dello start';
                return returnObj;
            }

            returnObj.success = true;
            return returnObj;

        }

        returnObj.success = true;
        return returnObj;
    }

    checkIsNotNull(valueToCheck){
        if(valueToCheck !== undefined && valueToCheck !== '' && valueToCheck !== null){
            return true;
        } else {
            return false;
        }        
    }

}