import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';

const columns = [
    {id:1, fieldName:'PersonalData__c'},
    {id:2, fieldName:'SupplyData__c'},
    {id:3, fieldName:'ServicePointCode__c'},
    {id:4, fieldName:'CraftsmenRegisterNumber__c'},
    {id:5, fieldName:'CheckActivityBox__c'},
    {id:6, fieldName:'AssociationStatute__c'},
    {id:7, fieldName:'Signature__c'},
    {id:8, fieldName:'CciaaData__c'},
    {id:9, fieldName:'CciaaSelfCertModule__c'},
    {id:10, fieldName:'AtecoCode__c'},
    {id:11, fieldName:'RequiredOfficeActivity__c'},
    {id:12, fieldName:'IdentityDocument__c'},
    {id:13, fieldName:'TaxesModule__c'}
];

export default class HdtDocumentValidation extends LightningElement {


    @api recordId;
    @api saveInDraft;
    @api cancelCase;
    @api documentValidated

    @api availableActions = [];

    checkboxField = columns;


    handleSuccess(){}

    handleSubmit(event){

        event.preventDefault();

        let count = 0;

        let size = 0;

        var fields = event.detail.fields

        this.template.querySelectorAll('lightning-input-field').forEach(element =>{

            ++size;

            console.log('Field Value --> '+element.value);

            if(element.value){

                ++count;

            }


        })

        if(count == size){

            this.documentValidated = true;

        }else{

            this.documentValidated = false;

        }

        console.log('Document Validated? --> '+this.documentValidated);

        this.template.querySelector('lightning-record-edit-form').submit(fields);

        this.handleGoNext();


        /*fields.forEach(element =>{

            console.log('#Field Value --> '+element.value);


        })*/


    }

    handleGoNext(){

        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    handleGoBack(){

        const navigateBackEvent = new FlowNavigationBackEvent();
        
        this.dispatchEvent(navigateBackEvent);

    }
    



}