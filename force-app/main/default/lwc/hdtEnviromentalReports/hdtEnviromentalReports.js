import {api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HdtRecordEditFormFlow from 'c/hdtRecordEditFormFlow';
import getMaterialOptions from '@salesforce/apex/HDT_UTL_SegnalazioniTariValidation.getMaterialOptions';

export default class HdtEnviromentalReports extends HdtRecordEditFormFlow {
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
    @api sessionid;

    _materialValue;

    get materialValue(){
        return this._materialValue;
    }
    set materialValue(value){
        const material = this.template.querySelector("[data-id='Material__c']");
        if(material){    
            material.value = value;
        }
        this._materialValue = value;
    }
    disableMaterial=true;
    operationGroupValue;
    operationTypeValue;
    get materialOptions(){
        return this._materialOptions;
    }

    set materialOptions(value){
        if(Array.isArray(value)){
            this._materialOptions = value;
        }
        else if(typeof value === "string"){
            this._materialOptions = [{label:this.materialValue, value: this.materialValue}];
        }
    }

    @track _materialOptions;

    handleOnLoad(event){
        let record = event.detail.records;
        let fields = record[this.recordId].fields;
        if(fields?.OperationGroup__c?.value){    this.operationGroupValue= fields?.OperationGroup__c?.value;   }
        if(fields?.TypeOperation__c?.value){     this.operationTypeValue= fields?.TypeOperation__c?.value;    }
        if(fields?.Material__c?.value){
            this.materialValue = fields?.Material__c?.value;
            this.materialOptions= this.materialOptions? this.materialOptions : this.materialValue;
        }
        this.showCustomLabels=true;
    }

    virtualChange(event){
        let fieldName = event.target.fieldName;
        let value = event.target.value;
        if(fieldName==="OperationGroup__c" || fieldName === "TypeOperation__c"){
            if(value){
                if(fieldName==="OperationGroup__c"){
                    this.operationGroupValue = value;
                    Promise.resolve().then(()=>{
                        this.operationTypeValue = this.template.querySelector("[data-id='TypeOperation__c']")?.value;
                        //this.materialValue = this.template.querySelector("[data-id='Material__c']")?.value;
                        if(!this.operationTypeValue){
                            this.disableMaterial=true;
                        }
                    });
                }else{
                    this.operationTypeValue = value;
                    /*Promise.resolve().then(()=>{
                        this.materialValue = this.template.querySelector("[data-id='Material__c']")?.value;
                        this.disableMaterial=false;
                    });*/
                }
            }else{
                this.materialValue = null;
                this.disableMaterial=true;
            }
        }
        return;
    }

    
    @wire(getMaterialOptions, { operationGroup: '$operationGroupValue', operationType: '$operationTypeValue' })
    wiredMaterials({ error, data }) {
        if (data) {
            this.error = undefined;
            let blankMaterial = true;
            this.materialOptions = data?.map(el=>{
                if(this.materialValue === el.Material__c)   blankMaterial = false;
                return {label: el.Material__c, value: el.Material__c};
            });
            if(this.materialOptions.length){
                this.disableMaterial=false;
                if(this.materialOptions.length === 1){   this.materialValue = this.materialOptions[0].value;    }
                else if(blankMaterial){   this.materialValue = null;  }
            }else{
                this.materialValue = null;
                this.showMessage("Attenzione", "Non è stata trovata una combinazione valida per Gruppo Intervento, Tipo Intervento e Materiale. Aprire segnalazione per notificare la problematica.", "error");
            }
        }else if(error){
            this.error= error;
        }
    }

    handleMaterialChange(event){
        console.log("material change");
        this.materialValue = event.detail.value;
    }

    handleSubmit(event){
        if(!this.materialValue){
            event.preventDefault();
            this.disableMaterial=false;
            Promise.resolve().then(()=>{
                this.template.querySelectorAll("lightning-combobox")[0].reportValidity();
                this.disableMaterial=true;
            });
            return;
        }
        super.handleSubmit(event);
    }

}