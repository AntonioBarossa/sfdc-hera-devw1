import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HdtRecordEditFormFlow from 'c/hdtRecordEditFormFlow';
import getSecondLevelOptions from '@salesforce/apex/HDT_QR_ProcessPostSales.getSecondLevelOptions';


export default class HdtEnvironmentalComplaintsReclassification extends HdtRecordEditFormFlow {

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

    @track _secondOptions = [{label: '--None--', value: null}];

    _secondValue;

    get secondValue(){
        return this._secondValue;
    }

    set secondValue(value){
        const secondFields = this.template.querySelector("[data-id='SecondLevelComplaintClassification__c']");
        if(secondFields){    
            secondFields.value = value;
        }
        this._secondValue = value;
    }

    get readOnlyMap(){
        return _readOnlyMap;
    }

    get secondOptions(){
        return this._secondOptions;
    }

    set secondOptions(value){
        if(Array.isArray(value)){
            this._secondOptions = value;
        }
        else if(typeof value === "string"){
            this._secondOptions = [{label:this.materialValue, value: this.materialValue}];
        }
    }


    handleSecondChange(event){
        this.secondValue = event.detail.value;
    }

    handleOnLoad(event){
        let record = event.detail.records;
        let fields = record[this.recordId].fields;
        if(fields?.SecondLevelComplaintClassification__c?.value){
            this.secondValue = fields?.SecondLevelComplaintClassification__c?.value;
            this.secondOptions = this.secondOptions? this.secondOptions : this.secondValue;
        }else{
            this.secondValue = this.secondOptions[0].value;
        }
        this.showCustomLabels=true;
    }

    @wire(getSecondLevelOptions)
    wiredSecondLevel({ error, data }) {
        if (data) {
            this.error = undefined;
            let blankSecond = true;
            this.secondOptions = this.secondOptions.concat(data?.map(el=>{
                if(this.secondValue === el.Value__c)   blankSecond = false;
                return {label: el.Value__c, value: el.Value__c};
            }));
            if(this.secondOptions.length){
                if(this.secondOptions.length === 1){   this.secondValue = this.secondOptions[0].value;    }
                else if(this.secondOptions.length === 2){   this.secondValue = this.secondOptions[1].value;    }
                else if(blankSecond){   this.secondValue = null;  }
            }else{
                this.secondValue = null;
                this.showMessage("Attenzione", "Non è stato trovato nessun valore disponibile per la classificazione di secondo livello", "error");
            }
        }else if(error){
            this.error= error;
        }
    }

}