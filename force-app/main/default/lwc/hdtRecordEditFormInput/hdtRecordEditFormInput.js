import { LightningElement,api,track,wire } from 'lwc';
import recordEditFormReqField from '@salesforce/label/c.recordEditFormReqField';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtRecordEditFormInput extends LightningElement {

    @api field;
    @api density;
    @api recordId;
    @api objectName;
    @track retrieveFields=[];
    labels={recordEditFormReqField};
    customFieldValue;
    customPicklistOptions=[];
    dataLoaded=false;
    
    @wire(getRecord, { recordId: '$recordId', fields: '$retrieveFields' })
    wiredRecord({ error, data }) {
        if(data && data.fields[this.field.FieldName].value != null) {
            this.customPicklistOptions.push({label:data.fields[this.field.FieldName].displayValue,value:data.fields[this.field.FieldName].value});
            this.customFieldValue=data.fields[this.field.FieldName].value;
            this.dataLoaded=true; 
        }
        if(data && data.fields[this.field.FieldName].value == null) this.dataLoaded=true;
        if(error) this.dataLoaded=true;
    }

    connectedCallback(){
        if(this.retrieveFields.length==0) this.retrieveFields.push(this.objectName+'.'+this.field.FieldName);
        if(this.customPicklistOptions.length<JSON.parse(JSON.stringify(this.field.PicklistOptions)).length) this.customPicklistOptions=this.customPicklistOptions.concat(JSON.parse(JSON.stringify(this.field.PicklistOptions)));
    }

    get options() {
        return this.customPicklistOptions;
    }

    handleChangeField(event){
        this.customFieldValue=event.detail.value;
        this.checkValidityCombo ? this.dispatchEvent(new CustomEvent('fieldchanged',{ detail: {api:this.field.FieldName,value:event.detail.value} })) : this.customFieldValue=''; 
    }

    @api getFieldValue(){
        return this.customFieldValue;
    }

    @api getFieldApi(){
        return this.field.FieldName;
    }

    @api checkValidityCombo(){
        if(this.field.Required && !this.template.querySelector('[data-id="combobox"]').reportValidity()) return false;
        return true;
    }

    @api getComboboxElement(){
        return this.template.querySelector('[data-id="combobox"]');
    }
}