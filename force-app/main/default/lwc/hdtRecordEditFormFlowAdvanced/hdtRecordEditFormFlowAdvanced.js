import {api} from 'lwc';
import HdtRecordEditFormFlow from 'c/hdtRecordEditFormFlow';

export default class HdtRecordEditFormFlowAdvanced extends HdtRecordEditFormFlow {

    @api processType;
    @api objectName;
    @api recordId;
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
    @api cancelCase;
    @api addContentDocument;
    @api contentDocumentLabel;
    @api acceptedFormats;
    @api nextStep;
    @api showReadOnly;
    @api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelInputSection;
    @api labelReadOnlySection;
    @api availableActions = [];
    @api variantSaveButton;
    @api outputId;
    @api documentRecordId;
    @api account;

    virtualValidate(event){
        console.log('event -> ' + event);
        if(event.target.fieldName == 'SubscriberType__c' && event.target.value == 'Soggetto Passivo'){
            this.template.querySelector("[data-id='FirstName__c']").value = this.account.Name;
            this.template.querySelector("[data-id='LastName__c']").value = this.account.LastName__c;
            this.template.querySelector("[data-id='Birthday__c']").value = this.account.BirthDate__c;
            this.template.querySelector("[data-id='Birthcity__c']").value = this.account.BirthProvince__c;
            this.template.querySelector("[data-id='AlternativeAddress__c']").value = this.account.BillingAddressFormula__c;
        }
    }
}