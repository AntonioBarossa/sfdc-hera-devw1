import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OWNER_ID from '@salesforce/schema/Lead.OwnerId';
import VISIT_ASSIGNMENT_RULES_OBJECT from '@salesforce/schema/VisitAssignmentRules__c';
import CATEGORY from '@salesforce/schema/VisitAssignmentRules__c.Category__c';
import CONSUMPTION from '@salesforce/schema/lead.Consumption__c';
import createActivityFromLead from '@salesforce/apex/HDT_LC_RequestVisitD2DCreateForm.createActivityFromLead';
import createVisitAssignmentRules from '@salesforce/apex/HDT_LC_RequestVisitD2DCreateForm.createVisitAssignmentRules';
import { NavigationMixin } from 'lightning/navigation';

const fields = [OWNER_ID];

export default class HdtRequestVisitD2DLead  extends NavigationMixin(LightningElement)  {

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
        
        let zipCode= this.template.querySelector('[data-id = "zipCodeField"]').value;
        let category = this.template.querySelector('[data-id = "categoryField"]').value;
        let consumption = this.template.querySelector('[data-id = "consumptionField"]').value;

        console.log('prova' + zipCode);
        console.log('test' + category);
       console.log('mobile'+consumption);
        if(zipCode != undefined && category != undefined && consumption != undefined){
            this.showSpinner=true;

            createActivityFromLead({
                leadId : this.recordId,
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
                dispatchEvent(new CustomEvent('afterSubmit')); 
                console.log(JSON.stringify(result));
                //this.dispatchEvent(new CloseActionScreenEvent());
                this.showSpinner = false;
                this.closeQuickAction();

               
                
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
            this.showSpinner = false;
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
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}