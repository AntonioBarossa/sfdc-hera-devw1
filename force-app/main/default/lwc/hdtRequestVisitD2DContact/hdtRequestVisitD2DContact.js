import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import {getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OWNER_ID from '@salesforce/schema/contact.OwnerId';
import VISIT_ASSIGNMENT_RULES_OBJECT from '@salesforce/schema/VisitAssignmentRules__c';
import CATEGORY from '@salesforce/schema/VisitAssignmentRules__c.Category__c';
import CONSUMPTION from '@salesforce/schema/Contact.Consumption__c';
import createActivityFromLead from '@salesforce/apex/HDT_LC_RequestVisitD2DCreateForm.createActivityFromContact';
import createVisitAssignmentRules from '@salesforce/apex/HDT_LC_RequestVisitD2DCreateForm.createVisitAssignmentRules';
const fields = [OWNER_ID];

export default class HdtRequestVisitD2DLead extends LightningElement {

    @api recordId;
    @track leadId;
    @track ownerId;
    //@track categoryOptions = ;
    @track consumptionOptions;
    @api zipCode;
    @api zipCodeValue
    @api category;
    @api consumptionValues;
    @api consumption;
    @track showSpinner = false;
    @track categoryValue;

    @wire(getObjectInfo, { objectApiName: VISIT_ASSIGNMENT_RULES_OBJECT })

    visitAssignmentRulesData;

    get categoryOptions() {
        return [
            { label: 'Azienda', value: 'Azienda' }
        ];
    }


/*
    @wire(getPicklistValues, {recordTypeId: '$visitAssignmentRulesData.data.defaultRecordTypeId' , fieldApiName: CATEGORY })
    categoryOptions({error, data}) {
        if(data){
            this.categoryOptions = data.values;
        }
    }*/

    @wire(getPicklistValues, {recordTypeId: '$visitAssignmentRulesData.data.defaultRecordTypeId' , fieldApiName: CONSUMPTION })
    consumptionOptions({error, data}) {
        if(data){
            this.consumptionOptions = data.values;
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields})
    wiredOwnerId({error, data}){
       if(data){

           this.ownerId = getFieldValue(data, OWNER_ID);

           console.log(this.ownerId);

       }else if(error){

           console.log(error);

       }    
   }


    renderedCallback() {
        console.log(this.recordId);
        this.leadId = this.recordId;
    }

    handleSubmit(event){
        this.showSpinner = true; //HRAWRM-915 21/10/2021
        let zipCode= this.template.querySelector('[data-id = "zipCodeField"]').value;
        let category = this.template.querySelector('[data-id = "categoryField"]').value;
        let consumption = this.template.querySelector('[data-id = "consumptionField"]').value;

        console.log('prova' + zipCode);
        console.log('test' + category);
       console.log('mobile'+consumption);
        if(zipCode != undefined && category != undefined && consumption != undefined){

       
            createActivityFromLead({
                contactId : this.recordId,
                zipCode: zipCode,
                category: category,
                consumption: consumption,
                //ownerId: this.ownerId
            }).then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Visita D2D creata con successo!',
                    variant: 'success'
                }));
                this.closeQuickAction();//HRAWRM-915 21/10/2021
                this.showSpinner = false;//HRAWRM-915 21/10/2021
                dispatchEvent(new CustomEvent('afterSubmit')); 
                console.log(JSON.stringify(result));
                this.dispatchEvent(new CloseActionScreenEvent());
            }).catch(err => {
                console.log(JSON.stringify(err));
            });
        }
        else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Errore',
                message: 'valorizza tutti i campi',
                variant: 'error'
            }));
            dispatchEvent(new CustomEvent('afterSubmit')); 
        }
      /* createActivityFromLead({

        leadId: this.recordId,
        ownerId: this.ownerId,
        consumption: consumption,
        categoria : this.categoryValue,
        cap : this.zipCode

       }).then(result => {
            console.log(JSON.stringify(result));
        }).catch(err => {
            console.log(JSON.stringify(err));
        });
 */              

    }
    //HRAWRM-915 21/10/2021
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }//HRAWRM-915 21/10/2021

}