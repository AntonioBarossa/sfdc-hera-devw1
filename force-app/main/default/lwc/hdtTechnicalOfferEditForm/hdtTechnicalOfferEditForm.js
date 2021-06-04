import { LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class HdtTechnicalOfferEditForm extends LightningElement {

    @api productId;
    @api rateObj;
    technicalOfferId = '';
    techOffId;
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

    connectedCallback(){
        
        if(this.rateObj.rateName!=null && this.rateObj.rateName != undefined){
            console.log('>>> rate: ' + this.rateObj.rateName);
        }

        if(this.rateObj.rateTemplate!=null && this.rateObj.rateTemplate != undefined){
            console.log('>>> template: ' + this.rateObj.rateTemplate);
        }

        if(this.rateObj.servProduct!=null && this.rateObj.servProduct != undefined){
            console.log('>>> servProduct: ' + this.rateObj.servProduct);
        }

    }

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
        //const fields = this.template.querySelectorAll('lightning-input-field');
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            techOffObj[field.fieldName] = field.value;
        });

        if(this.rateObj.servProduct!=null && this.rateObj.servProduct != undefined){
            techOffObj.ServiceProduct__c = this.rateObj.servProduct;
        }

        var respCheck = this.checkValue(techOffObj);
        console.log('#### ' + respCheck.success);

        if(!respCheck.success){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: respCheck.message,
                    variant: 'warning'
                })
            );
            return;
        }


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