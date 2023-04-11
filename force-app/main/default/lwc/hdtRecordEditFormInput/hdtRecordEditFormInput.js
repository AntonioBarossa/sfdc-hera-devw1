import { LightningElement,api,track,wire } from 'lwc';
import recordEditFormReqField from '@salesforce/label/c.recordEditFormReqField';
import init from '@salesforce/apex/HDT_LC_RecordEditFormInputController.init';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtRecordEditFormInput extends LightningElement {

    @api field;
    @api density;
    @api recordId;
    @api objectName;
    @api index;
    @api controllingField;
    @track retrieveFields=[];
    labels={recordEditFormReqField};
    customFieldValue;
    customPicklistOptions=[];
    dataLoaded=false;

    /*
    @wire(getRecord, { recordId: '$recordId', fields: '$retrieveFields' })
    wiredRecord({ error, data }) {
        if(data && data.fields[this.field.FieldName].value != null) {
            if(!this.customPicklistOptions.find(elem=> (elem?.value!=null &&  elem.value == data.fields[this.field.FieldName].value))){
                this.customPicklistOptions.push({label:data.fields[this.field.FieldName].displayValue,value:data.fields[this.field.FieldName].value});
            }

        }
        if(data && data.fields[this.field.FieldName].value == null) this.dataLoaded=true;
        if(error) this.dataLoaded=true;
    }
    */
    connectedCallback(){
        if(this.retrieveFields.length==0) this.retrieveFields.push(this.objectName+'.'+this.field.FieldName);
        if(this.customPicklistOptions.length<JSON.parse(JSON.stringify(this.field.PicklistOptions)).length) this.customPicklistOptions=this.customPicklistOptions.concat(JSON.parse(JSON.stringify(this.field.PicklistOptions)));
        let paramsObj={
            'fieldName':this.field.FieldName,
            'objectId':this.recordId,
            'controllingField':this.controllingField ? this.controllingField:'',
            'process':'test'
        }
        debugger;
        init({params:paramsObj})
        .then(data=>{
            console.log('init method start');
            if(data && !this.controllingField && data.fieldValue && data.fieldLabel){
                if(!this.customPicklistOptions.find(elem=> (elem?.value!=null &&  elem.value == data.fieldValue))) this.customPicklistOptions.push({label:data.fieldLabel,value:data.fieldValue});
                this.customFieldValue=data.fieldValue;
            }
            this.dataLoaded=true;
        })
        .catch(error => {
            console.log('error');
        });
    }

    get options() {
        return this.customPicklistOptions;
    }

    handleChangeField(event){
        this.customFieldValue=event.detail.value;
        if(this.checkValidityCombo()){
            this.removeErrorClass()
            this.dispatchEvent(new CustomEvent('fieldchanged',{ detail: {api:this.field.FieldName,value:event.detail.value} }))
        } else {
            this.customFieldValue='';
            this.addErrorClass();
        }
    }

    @api checkValidityCombo(){
        console.log('check validity combo started');
        if(this.field.Required && !this.template.querySelector('[data-id="combobox"]').value){
            this.addErrorClass();
            return false;
        }
        this.removeErrorClass();
        return true;
    }

    addErrorClass(){
        this.template.querySelector('[data-id="combobox"]').classList.add('slds-has-error');
        this.template.querySelector('[data-id="errorHelpText"]').classList.remove('slds-hidden');
    }

    removeErrorClass(){
        this.template.querySelector('[data-id="combobox"]').classList.remove('slds-has-error');
        this.template.querySelector('[data-id="errorHelpText"]').classList.add('slds-hidden');
    }

    @api getFieldValue(){
        return this.customFieldValue;
    }

    @api getFieldApi(){
        return this.field.FieldName;
    }

    get idCalculator(){
        return 'customcombobox'+this.index;
    }

    @api getComboboxElement(){
        return this.template.querySelector('[data-id="combobox"]');
    }
}