/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */

import lookUp from '@salesforce/apex/HDT_LC_CustomLookupController.lookUpWithOrderBy';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

const FIELDS = [];
const BOX_OPEN = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
const BOX_CLOSED = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';

export default class LookupLwc extends LightningElement {

    @api valueId;
    @api objName;
    @api iconName;
    @api labelName;
    @api readOnly = false;
    @api filter;
    @api showLabel = false;
    @api uniqueKey;
    @api placeholder;
    @api searchBy;
    @api setAsKey;
    @api orderBy = "";
    @api detailFields;
    @api eventOnGetRecord = "false";
    @api required = "false";
    //AGGIUNTO NEL CASO DI RECLAMO
    @api isReclamo = false;
    //AGGIUNTO NEL CASO DI RECLAMO
    objLabelName;
    searchTerm;
    @track valueObj;
    @track options; //lookup values
    @track isValue;
    @track blurTimeout;
    blurTimeout;

    //css
    @track boxClass = BOX_CLOSED;
    @track inputClass = '';    

    get req() {
        return this.required === "true";
    }

    connectedCallback() {
        console.log("objName", this.objName);
        
        if(this.detailFields===undefined){
            this.detailFields = [];
        }

        if(this.filter===undefined){
            this.filter = '';
        }

        if(FIELDS.length === 0){
            FIELDS.push(this.objName + '.' + this.searchBy);
            FIELDS.push(this.objName + '.' + this.setAsKey);
            FIELDS.push(this.objName + '.Name');
        }
        console.log("FIELDS", FIELDS);
    }

    renderedCallback() {
        if(this.objName) {
            let temp = this.objName;
            if(temp.includes('__c')){
                let newObjName = temp.replace(/__c/g,"");
                if(newObjName.includes('_')) {
                    let vNewObjName = newObjName.replace(/_/g," ");
                    this.objLabelName = vNewObjName;
                }else {
                    this.objLabelName = newObjName;
                }
                
            }else {
                this.objLabelName = this.objName;
            }
        }

        console.log("# Rendered: ", this.objName);
    }

    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter', searchBy: '$searchBy', setAsKey: '$setAsKey', orderBy: '$orderBy', detailFields: '$detailFields'})
    wiredRecords({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.options = this.record;
            //console.log("# lookup result: ", JSON.stringify(this.options));

            if(this.options.length===0){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Nessune risultato trovato',
                        variant: 'warning'
                    }),
                );
            }

        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("# wire error",this.error);
        }
    }

    //To get preselected or selected record
    @wire(getRecord, { recordId: '$valueId', fields: FIELDS })
    wiredOptions({ error, data }) {
        if (data) {
            console.log("# record: ", JSON.stringify(data));
            this.record = data;
            this.error = undefined;
            this.valueObj = this.record.fields[this.searchBy].value;
            this.isValue = true;
            if (this.eventOnGetRecord === "true") {                
                const valueSelectedEvent = new CustomEvent('valueselect', {
                    detail: { selectedId: data.fields["id"], code: data.fields[this.searchBy].value, name: data.fields["Name"].value}
                });
                this.dispatchEvent(valueSelectedEvent);                
            }
            //console.log("# record: ", JSON.stringify(this.record));
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("# error: ", this.error);
        }
    }

    //when valueId changes
    valueChange() {
        console.log("# valueChange #");
    }

    handleClick() {
        console.log("# handleClick #");

        try {

            this.searchTerm = '';
            this.inputClass = 'slds-has-focus';
            this.boxClass = BOX_OPEN;
            
        } catch (error) {
            console.error(error);
        }
        
        //let combobox = this.template.querySelector('#box');
        //combobox.classList.add("slds-is-open"); 
    }

    inblur() {
        console.log("# inblur #");
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = setTimeout(() =>  {this.boxClass = BOX_CLOSED}, 200);
    }

    onSelect(event) {
        console.log("# onSelect #");
        let ele = event.currentTarget;
        let selectedObj = ele.dataset;
        //As a best practise sending selected value to parent and inreturn parent sends the value to @api valueId
        //let key = this.uniqueKey;
        console.log("# selectedId: " + selectedObj.id + ' # name: ' + selectedObj.name + ' # code: ' + selectedObj.code);
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId: selectedObj.id, code: selectedObj.code, name: selectedObj.name}
        });
        this.dispatchEvent(valueSelectedEvent);

        this.valueObj = selectedObj.name;
        this.isValue = !this.isReclamo;

        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = BOX_CLOSED;
    }

    onChange(event) {
        console.log("# onChange #");
        this.searchTerm = event.target.value;
        console.log("searchTerm",this.searchTerm);
    }

    handleRemovePill() {
        console.log("# handleRemovePill #");
        this.isValue = false;
        let selectedId = '';
        let key = this.uniqueKey;
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key },
        });
        this.dispatchEvent(valueSelectedEvent);
        this.reportValidity();
    }

    closeModal() {
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
        this.createRecordOpen = false;
        this.recordTypeSelector = false;
        this.mainRecord = false;
    }

    @api
    reportValidity() {
        console.log(this.required);
        console.log(typeof this.required);
        if (this.required === "true") {
            let interalId = window.setInterval(() => {
                this.template.querySelector('[data-id="input"]')?.reportValidity();
                if (this.template.querySelector('[data-id="input"]')) {
                    window.clearInterval(interalId);
                }
            }, 50);
            
        }        
    }
}