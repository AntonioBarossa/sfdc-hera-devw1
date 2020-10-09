import { LightningElement, api, track } from 'lwc';

export default class hdtTargetObjectAddressFields extends LightningElement {
    @api objectapiname;
    @api fieldsaddress;
    @track submitedAddressFields = {};
    get verifyFieldsAddressDisabled(){
        let result = true;

        if(
            (this.submitedAddressFields.SupplyCountry__c != undefined
            && this.submitedAddressFields.SupplyCity__c != undefined
            && this.submitedAddressFields.SupplyPostalCode__c != undefined)
            &&
            (this.submitedAddressFields.SupplyCountry__c != ''
            && this.submitedAddressFields.SupplyCity__c != ''
            && this.submitedAddressFields.SupplyPostalCode__c != '')
        ){
            result = false;
        }

        this.dispatchEvent(new CustomEvent("verifyfieldsaddressdisabled", {
            detail: result
          }));
        
        return result;
    }

    handleFieldsDataChange(event){

        this.submitedAddressFields[event.target.fieldName] = event.target.value;
        
        let evt = new CustomEvent("getaddressfields", {
            detail: this.submitedAddressFields
          });

        this.dispatchEvent(evt);

    }

}