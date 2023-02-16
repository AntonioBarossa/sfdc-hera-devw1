import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import LNDRGS_OBJ from '@salesforce/schema/LandRegistry__c';
import getCadastralCategories from '@salesforce/apex/HDT_UTL_LandRegistry.getCadastralCategories';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';
import getCadastralRecord from '@salesforce/apex/HDT_UTL_LandRegistry.getCadastralRecord';

const RT_NAME = 'DatiCatastali - Pratica Ambiente';
const FORM_LOAD_TO_DO = 'TO_DO';
const FORM_LOAD_ALMOST_DONE = 'ALMOST_DONE';
const FORM_LOAD_DONE = 'DONE';

export default class HdtLandRegistryEdit extends LightningElement {
    @wire(getObjectInfo, { objectApiName: LNDRGS_OBJ })
    objectInfo;

    @api get recordId(){
        return this._recordId;
    }
    set recordId(newValue){
        if(this._recordId != newValue){
            this.showSpinner = true;
            this.formLoaded = FORM_LOAD_TO_DO;
            if(this._recordId == null) this.firstLoad = true;
            this._recordId = newValue;
        }
    }
    @api orderId;
    @api caseId;
    @api servicePointId;
    @api required;
    @api readonly;
    @api showEdit;
    @api showDelete;

    get rtIdTari(){
        let rtId;
        if(this.objectInfo.data){
            const recordTypesMap = this.objectInfo.data.recordTypeInfos;
            const foundRt = Object.values(recordTypesMap).find( element => element.name === RT_NAME );
            if(foundRt) rtId = foundRt.recordTypeId;
        }
        return rtId;
    }

    get disableModifica(){ return this.modify || !this._recordId || this._recordId == '' || this._readonly }
    get disableForm(){ return !this.modify || this._readonly };
    disableSalva = true;
    disableElimina = true;
    modify = false;

    // showForm = false;
    showSpinner = false;
    firstLoad = true;
    formLoaded;

    cadastralCategories = [];
    cityTechnicalData = new Map();
    cadastralCategoryOptions = [];
    cityOptions = [];
    
    registryCityValue;
    legalCityValue;
    registryCityCodeValue;
    provinceValue;
    cadastralCategoryValue;

    _recordId = null;
    _required = true;
    _readonly;
    _showEdit;
    _showDelete;

    connectedCallback(){
        this.call_getCadastralCategories();
        //this.call_getCities();
        this._required = this.required == false ? false : true;
        this._readonly = this.readonly;
        this._showEdit = this.showEdit;
        this._showDelete = this.showDelete;
    }

    handleFieldChange(event) {
        console.log("### handleFieldChange", event.target.name, event.target.fieldName);
        const source = event.target.name ? event.target.name : event.target.fieldName;
        if(this.formLoaded == FORM_LOAD_DONE){
            this.disableSalva = false;
            if(source == "CodeMissingRegistryData__c") {
                if(event.detail.value == ""){
                    this._required = this.required == false ? false : true;
                }else{
                    this._required = false;
                    let inputList = this.template.querySelectorAll('lightning-input-field');
                    inputList.forEach(input => {
                        if(!["CodeMissingRegistryData__c", "ServicePoint__c"].includes(input.fieldName)) input.value = null
                    });
                    inputList = this.template.querySelectorAll('lightning-combobox');
                    inputList.forEach(input => input.value = null);
                    this.registryCityValue = null;
                    //this.legalCityValue = null;
                    this.registryCityCodeValue = null;
                    this.provinceValue = null;
                    this.cadastralCategoryValue = null;
                }
            }
            if(source == "RegistryCityLookup__c" || source == "LegalCityLookup__c"){
                //const t0 = performance.now();
                this.template.querySelector('[data-name="LegalCityLookup__c"]').value = event.target.value;
                if(event.target.value){
                    this.showSpinner = true;
                    this.getCityRecord(event.target.value).then(result =>{
                        let foundCity = result[0];
                        if(source == "RegistryCityLookup__c"){
                            this.registryCityValue = foundCity.CadastralCity__c;
                            this.legalCityValue = foundCity.CadastralCity__c;
                            this.registryCityCodeValue = foundCity.CityCode__c;
                            this.provinceValue = foundCity.Province__c;
                        }else{
                            this.legalCityValue = foundCity.CadastralCity__c;
                        }
                        if(this._required){
                            this.checkRequiredFields();
                        }
                    }).catch(error=>{
                        console.log("error on getCity")
                        console.log(error);
                    }).finally(()=>{
                        this.showSpinner = false;
                    });
                    return;
                }
                //const t1 = performance.now();
                //console.log(`Call to doSomething took ${t1 - t0} milliseconds.`);
                //console.log('@@@@@@@@@@@@ test mappa '+JSON.stringify(foundCity));
                
            }
            if(["Sheet__c", "ParticleSheet__c", "Subaltern__c"].includes(source)) {
                let val = event.target.value;
                while(val.startsWith("0")) val = val.slice(1);
                val = val.padStart(4, '0');
                this.template.querySelector('[data-id="'+source+'"]').value = val;
                let maxLengthReached = false;
                let msg;
                if(["Sheet__c", "Subaltern__c"].includes(source) && val.length > 4){
                    msg = 'Lunghezza massima '+(source == "Sheet__c" ? "Foglio" : "Subalterno")+' 4 caratteri';
                    maxLengthReached = true;
                }
                if("ParticleSheet__c" == source && val.length > 5){
                    msg = 'Lunghezza massima Particella 5 caratteri';
                    maxLengthReached = true;
                }
                if(maxLengthReached){
                    const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: msg });
                    this.dispatchEvent(evt);
                    this.disableSalva=true;
                }
                //else this.disableSalva=false;
            }
            if(source == "UrbanSection__c") {
                const curLength = event.target.value.length;
                if(curLength>3) {
                    const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Sezione Urbana 3 Caratteri' });
                    this.dispatchEvent(evt);
                    this.disableSalva=true;
                } 
                //else this.disableSalva=false;
            }
            if(source == "RegistryCategory__c") {
                this.cadastralCategoryValue = event.target.value;
            }
            if(source == "RegistrySurface__c"){
                let val = event.target.value;
                if(val == 0){
                    let msg = "valori maggiori o uguali a 1";
                    const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: msg });
                    this.dispatchEvent(evt);
                    this.disableSalva=true;
                }
            }
            //controllo se abilitare o meno il salva in base ai campi required
            //this.disableSalva = false;
            if(this._required){
                this.checkRequiredFields();
            }
        }
    }

    @api checkRequiredFields(){
        let inputList = this.template.querySelectorAll('lightning-input-field:not(.slds-hide)');
        inputList.forEach(input => {
            if(input.fieldName != "CodeMissingRegistryData__c" && 
            (input.value == null || (input.value == "" && typeof(input.value)!= "number"))  &&
            input.required){
                this.disableSalva = true;
            }
        });
        inputList = this.template.querySelectorAll('lightning-combobox');
        inputList.forEach(input => {
            if((input.value == null || input.value == "") &&
            input.required) {
                this.disableSalva = true;
            }
        });
    }

    getCityRecord(lookupId){
        return getCadastralRecord({cadastralRecordId : lookupId});
    }

    handleModificaClick(){
        this.modify = true;
        this.disableSalva = true;
        this.dispatchEditEvt(true);
    }

    dispatchEditEvt(isEditing){
        this.dispatchEvent(new CustomEvent("editdata", {detail : {isEditing:isEditing}}));
    }

    handleRestore(){
        this.template.querySelectorAll('lightning-input-field:not(.slds-hide)')
        .forEach(field => {
            field.reset();
        });
        this.cadastralCategoryValue = this.template.querySelector('[data-name="RegistryCategory__c"]').value;
        this.modify = false;
        this.disableSalva = true;
        this.dispatchEvent(new CustomEvent("editdata", {detail : {isEditing:false, restoredId: this._recordId}}));
    }

    handleEliminaClick(){
        this.showSpinner = true;
        let recordId = this._recordId;
        this._recordId = null;
        deleteRecord(recordId)
            .then(() => { 
                this.throwDeletionEvent() 
            })
            .catch(error => {
                console.error("### handleEliminaClick Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });

    }

    @api
    validateForm(){
        const reg = new RegExp('^\\*?(.+)\\n?');
        const valuation = [
                ...this.template.querySelectorAll('lightning-input-field:not(.slds-hide)')
            ].reduce(
                (Fields, elem) => {
                        if(elem.value !== false && elem.required && !(elem.value)){
                            let fname = elem.outerText?.match(reg)?.[1];
                            Fields.labels+=`, ${fname}`;
                            Fields.apinames.push(elem.fieldName);
                        }
                        return Fields;
                    }, {labels : "", apinames : []}
                );
        console.log("missing fields "+valuation.apinames);
        const message = valuation.labels.slice(2);
        if(message){
            this.showMessage('Errore', 'Popolare i campi obbligatori: '+message, 'error');
            return true;
        }
    }

    showMessage(title,message,variant)
    {
        this.loading = false;
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastErrorMessage);
    }

    

    handleFormLoad(event){
        this.showSpinner = false;
        console.log("### handleFormLoad", JSON.stringify(event.detail.records));
        this.modify = true; // => presetto il form come modificabile, poi lo disabilito se ci sono le condizioni
        if(this._recordId){
            this.modify = false;
            const recordUi = event.detail.records[this._recordId];
            if(recordUi){
                this.disableElimina = false;
                this.registryCityValue = recordUi.fields.RegistryCity__c?.value;
                this.registryCityCodeValue = recordUi.fields.RegistryCityCode__c?.value;
                //this.legalCityValue = recordUi.fields.LegalCity__c?.value;
                this.provinceValue = recordUi.fields.Province__c?.value;
                this.cadastralCategoryValue = recordUi.fields.RegistryCategory__c?.value;
            }
        }
        else{
            this.formLoaded = FORM_LOAD_DONE;
            this.disableElimina = true;
            this.registryCityValue = null;
            this.registryCityCodeValue = null;
            this.legalCityValue = null;
            this.provinceValue = null;
            this.cadastralCategoryValue = null;
        }
        if(this.firstLoad){
            this.formLoaded = FORM_LOAD_DONE;
            this.firstLoad = false;
        }
        else{
            switch (this.formLoaded) {
                case FORM_LOAD_ALMOST_DONE:
                    this.formLoaded = FORM_LOAD_DONE;
                    break;
                case FORM_LOAD_TO_DO:
                    this.formLoaded = FORM_LOAD_ALMOST_DONE;
                    break;
                default:
                    console.log("### handleFormLoad status", this.formLoaded);
            }
        }
        if(!this._showEdit) this.modify = true;
        let inputList = this.template.querySelectorAll('lightning-input-field');
        inputList.forEach(input => { 
            if( "CodeMissingRegistryData__c" == input.fieldName ){
                if([ null, "" ].includes(input.value)) this._required = this.required == false ? false : true;
                else this._required = false;
            }
        });
    }

    handleFormSubmit(event){
        this.modify = false;
        console.log("### handleFormSubmit", JSON.stringify(event.detail.fields));
        event.preventDefault();
        event.detail.fields.RegistryCity__c = this.registryCityValue;
        event.detail.fields.LegalCity__c = this.legalCityValue;
        event.detail.fields.RegistryCategory__c = this.cadastralCategoryValue;
        event.detail.fields.Status__c = "Bozza";
        event.detail.fields.Case__c = this.caseId;
        event.detail.fields.Order__c = this.orderId;
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        this.disableSalva=true;
        this.showSpinner = true;
    }

    handleFormSuccess(event){
        console.log("### handleFormSuccess", JSON.stringify(event.detail));
        this._recordId=event.detail.id;
        const evt = new ShowToastEvent({ variant: 'success', title: 'Operazione eseguita correttamente!', message: 'Record salvato.' });
        this.dispatchEvent(evt);
        this.throwSuccessEvent();
        this.template.querySelector('[data-name="RegistryCategory__c"]').value = this.cadastralCategoryValue;
        this.showSpinner = false;
        this.dispatchEditEvt(false);
    }

    handleFormError(event){
        console.error("### handleFormError", event.detail.detail);
        const evt = new ShowToastEvent({ variant: 'error', title: 'Operazione non eseguita!', message: 'Errore ' + event.detail.detail });
        this.dispatchEvent(evt);
        this.dispatchEditEvt(false);
        this.showSpinner = false;
    }

    call_getCadastralCategories() {
        console.log('### call_getCadastralCategories');
        this.showSpinner = true;
        getCadastralCategories({})
            .then(result => {
                console.log('### result -> getCadastralCategories', JSON.stringify(result));
                this.cadastralCategoryOptions = result.map(
                    currentElement => {
                    return {
                        label: ''+currentElement.Category__c+' - '+currentElement.Description__c, 
                        value: currentElement.Category__c
                    };
                });

            })
            .catch(error => {
                console.error("### call_getCadastralCategories Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    /*call_getCities() {
        console.log('### call_getCities');
        this.showSpinner = true;
        getCities({ })
            .then(result => {
                //console.log('### result -> getCities', JSON.stringify(result));
                //const t0 = performance.now();
                //this.cityTechnicalData = result;
                let cityOptions = [];
                for(const currentElement of result){
                    this.cityTechnicalData.set(currentElement.CadastralCity__c, currentElement);
                    cityOptions.push({label: currentElement.CadastralCity__c , value: currentElement.CadastralCity__c});
                }
                this.cityOptions = cityOptions;
                //const t1 = performance.now();
                //console.log(`Call to doSomething took ${t1 - t0} milliseconds.`);
            })
            .catch(error => {
                console.error("### call_getCities Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }*/
    
    throwSuccessEvent(){
        const evt = new CustomEvent("formsuccess", { detail:  {rowId: this._recordId} });
        this.dispatchEvent(evt);
    }
    
    throwDeletionEvent(){
        const evt = new CustomEvent("deletion", { detail:  {rowId: this._recordId} });
        this.dispatchEvent(evt);
    }
}