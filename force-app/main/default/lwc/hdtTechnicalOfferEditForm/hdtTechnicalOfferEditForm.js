import { LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import endDateError from '@salesforce/label/c.HDT_LWC_OfferEditForm_EndDateError';
import numberTimeError from '@salesforce/label/c.HDT_LWC_OfferEditForm_NumberTimeError';
import numberDaysMonthsYearsError from '@salesforce/label/c.HDT_LWC_OfferEditForm_NumberDaysMonthsYearsError';
import numberOfTimeUnitsError from '@salesforce/label/c.HDT_LWC_OfferEditForm_NumberOfTimeUnitsError';
import allFieldRequired from '@salesforce/label/c.HDT_LWC_OfferEditForm_AllFieldRequired';

export default class HdtTechnicalOfferEditForm extends LightningElement {

    label = {
        endDateError,
        numberTimeError,
        numberDaysMonthsYearsError,
        numberOfTimeUnitsError,
        allFieldRequired
    };

    @api productId;
    @api rateObj;
    fieldsList = [
        {fieldName: 'Market__c', required: true},
        {fieldName: 'ProcessType__c', required: false},
        {fieldName: 'PlacetOffer__c', required: true},
        //{fieldName: 'ServiceProduct__c', required: true},
        {fieldName: 'StartDate__c', required: true},
        {fieldName: 'EndDate__c', required: true},
        {fieldName: 'StepAllowed__c', required: true},
        {fieldName: 'ContractId__c', required: true},
        {fieldName: 'NumberTimeExtension__c', required: true},
        {fieldName: 'UnitTimeExtension__c', required: true},
        {fieldName: 'NumberDaysMonthsYears__c', required: true},
        {fieldName: 'UnitTerminationTime__c', required: true},
        {fieldName: 'CancellationAllowed__c', required: true},
        {fieldName: 'RecessAdmitted__c', required: true},
        {fieldName: 'NumberOfTimeUnits__c', required: true},
        {fieldName: 'UnitOfTimeMeasurement__c', required: true},
        {fieldName: 'AdmittingProfileModification__c', required: false},
        {fieldName: 'OfferToBeModified__c', required: false}
    ];

    @api mode;
    @api technicalOfferId;
    @api hidden;

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
            techOffObj[field.fieldName] = field.value;
        });

        var responseObj = this.checkValue(techOffObj);
        if(!responseObj.success){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: responseObj.message,
                    variant: 'warning',
                    mode: 'sticky'
                })
            );
            return;
        }

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
                returnObj.message = this.label.endDateError;
                return returnObj;
            }
            //returnObj.success = true;
            //return returnObj;
        }

        if(this.checkIsNotNull(techOffObj.NumberTimeExtension__c)){
            let isnum = /^\d+$/.test(techOffObj.NumberTimeExtension__c);
            if(!isnum){
                returnObj.message = this.label.numberTimeError;
                return returnObj;
            }
        }

        if(this.checkIsNotNull(techOffObj.NumberDaysMonthsYears__c)){
            let isnum = /^\d+$/.test(techOffObj.NumberDaysMonthsYears__c);
            if(!isnum){
                returnObj.message = this.label.numberDaysMonthsYearsError;
                return returnObj;
            }
        }

        if(this.checkIsNotNull(techOffObj.NumberOfTimeUnits__c)){
            let isnum = /^\d+$/.test(techOffObj.NumberOfTimeUnits__c);
            if(!isnum){
                returnObj.message = this.label.numberOfTimeUnitsError;
                return returnObj;             
            }
        }

        for(var i in techOffObj){
            //console.log('> > > > ' + i + ' - ' + techOffObj[i]);
            let foundField = this.fieldsList.find(field  => field.fieldName === i);
            //console.log('>>>> ' + JSON.stringify(foundField));
            if(!this.checkIsNotNull(techOffObj[i]) && foundField.required){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: this.label.allFieldRequired,
                        variant: 'warning',
                        mode: 'sticky'
                    })
                );
            }
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