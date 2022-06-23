import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import LNDRGS_OBJ from '@salesforce/schema/LandRegistry__c';
import getCadastralCategories from '@salesforce/apex/HDT_UTL_LandRegistry.getCadastralCategories';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';

const RT_NAME = 'Dati Catastali TARI';

export default class HdtLandRegistryEdit extends LightningElement {
    @wire(getObjectInfo, { objectApiName: LNDRGS_OBJ })
    objectInfo;

    @api get recordId(){
        return this._recordId;
    }
    set recordId(newValue){
        if(this._recordId != newValue){
            this.showSpinner = true;
            setFieldLoaded(true, false);
            this._recordId = newValue;
            this.showSalva=false;
            this.disableForm=true;
            if(this._recordId){
                let inputList = this.template.querySelectorAll('lightning-input-field');
                inputList.forEach(input => {
                    if("RegistryCity__c" == input.fieldName) this.registryCityValue = selectedRow.RegistryCity__c;
                    if("RegistryCityCode__c" == input.fieldName) this.registryCityCodeValue = selectedRow.RegistryCityCode__c;
                    if("LegalCity__c" == input.fieldName) this.legalCityValue = selectedRow.LegalCity__c;
                    if("Province__c" == input.fieldName) this.provinceValue = selectedRow.Province__c;
                    if("RegistryCategory__c" == input.fieldName) this.cadastralCategoryValue = selectedRow.RegistryCategory__c;
                });
            }
            else{
                this.registryCityValue = null;
                this.registryCityCodeValue = null;
                this.legalCityValue = null;
                this.provinceValue = null;
                this.cadastralCategoryValue = null;
            }
        }
    }
    @api servicePointId;
    @api required;
    @api readonly;
    @api showButtons;

    @api createNewRecord(){
        this.recordId=null;
    }

    get rtIdTari(){
        let rtId;
        if(this.objectInfo.data){
            const recordTypesMap = this.objectInfo.data.recordTypeInfos;
            const foundRt = Object.values(recordTypesMap).find( element => element.name === RT_NAME );
            if(foundRt) rtId = foundRt.recordTypeId;
        }
        return rtId;
    }

    get disableModifica(){ return !this._recordId || this._recordId == '' || this._readonly }
    disableSalva = false;
    disableForm = true;

    showSpinner = false;
    showSalva = false;

    cadastralCategories = [];
    cityTechnicalData = [];
    cadastralCategoryOptions = [];
    cityOptions = [];
    
    registryCityValue;
    legalCityValue;
    registryCityCodeValue;
    provinceValue;
    cadastralCategoryValue;

    _recordId;
    _required;
    _readonly;
    _showButtons = true;

    fieldsCmpLoaded = {
        CodeMissingRegistryData__c : false,
        DestinationUsage__c : false,
        RegistryCity__c : false,
        RegistryCityCode__c : false,
        LegalCity__c : false,
        Province__c : false,
        UnitType__c : false,
        UrbanSection__c : false,
        Sheet__c : false,
        ParticleSheet__c : false,
        Subaltern__c : false,
        RegistryCategory__c : false,
        RegistrySurface__c : false,
        Title__c : false
    };

    connectedCallback(){
        this.call_getCadastralCategories();
        this.call_getCities();
        this._required = this.required;
        this._readonly = this.readonly;
        if(this.showButtons) this._showButtons = this.showButtons;
        // this.setFieldLoaded(true, true);
    }

    handleFieldChange(event) {
        console.log("### handleFieldChange", event);
        this.disableSalva=false;
        const source = event.target.name ? event.target.name : event.target.fieldName;
        console.log("### handleFieldChange source", source);
        if(this.getFieldLoaded(false, source)){
            if(source == "CodeMissingRegistryData__c") {
                if(event.detail.value == "") this._required = this.required;
                else{
                    this._required = false;
                    let inputList = this.template.querySelectorAll('lightning-input-field');
                    inputList.forEach(input => {
                        if(!["CodeMissingRegistryData__c", "ServicePoint__c"].includes(input.fieldName)) input.value = null
                    });
                    inputList = this.template.querySelectorAll('lightning-combobox');
                    inputList.forEach(input => input.value = null);
                    this.registryCityValue = null;
                    this.legalCityValue = null;
                    this.registryCityCodeValue = null;
                    this.provinceValue = null;
                    this.cadastralCategoryValue = null;
                }
            }
            if(source == "RegistryCity__c"){
                let foundCity = this.cityTechnicalData.find(element => element.CadastralCity__c == event.detail.value);
                this.registryCityValue = foundCity.CadastralCity__c;
                this.legalCityValue = foundCity.CadastralCity__c;
                this.registryCityCodeValue = foundCity.CityCode__c;
                this.provinceValue = foundCity.Province__c;
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
                else this.disableSalva=false;
            }
            if(source == "UrbanSection__c") {
                const curLength = event.target.value.length;
                if(curLength<=3) {
                    this.disableSalva=false;
                } else {
                    const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Sezione Urbana 3 Caratteri' });
                    this.dispatchEvent(evt);
                    this.disableSalva=true;
                }
            }
            if(source == "LegalCity__c") {
                this.legalCityValue = event.target.value;
            }
            if(source == "RegistryCategory__c") {
                this.cadastralCategoryValue = event.target.value;
            }
        }
        else this.setFieldLoaded(false, true, source);
    }

    handleModificaClick(){
        this.disableSalva=false;
        this.showSalva=true;
        this.disableForm=false;
    }

    handleEliminaClick(){
        let recordId = this._recordId;
        this._recordId = null;
        deleteRecord(recordId)
            .then(() => {
                this.throwDeletionEvent();
            })
            .catch(error => {
                console.error("### handleEliminaClick Errore", error);
            });
    }

    handleFormSubmit(event){
        console.log("### handleFormSubmit1", JSON.stringify(event.detail.fields));
        event.preventDefault();
        event.detail.fields.RegistryCity__c = this.registryCityValue;
        event.detail.fields.LegalCity__c = this.legalCityValue;
        event.detail.fields.RegistryCategory__c = this.cadastralCategoryValue;
        event.detail.fields.Status__c = "Bozza";
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        this.disableSalva=true;
    }

    handleFormSuccess(event){
        console.log("### handleFormSuccess", JSON.stringify(event.detail));
        this._recordId=event.detail.id;
        const evt = new ShowToastEvent({ variant: 'success', title: 'Operazione eseguita correttamente!', message: 'Record salvato.' });
        this.dispatchEvent(evt);
        this.throwSuccessEvent();
    }

    handleFormError(event){
        console.error("### handleFormError", event);
        this.showSpinner = false;
    }

    call_getCadastralCategories() {
        console.log('### call_getCadastralCategories');
        this.showSpinner = true;
        getCadastralCategories({})
            .then(result => {
                console.log('### result -> getCadastralCategories', JSON.stringify(result));
                this.cadastralCategories = result;
                for (var i = 0; i < result.length; i++) {
                    this.cadastralCategoryOptions=[...this.cadastralCategoryOptions,{label: ''+result[i].Category__c+' - '+result[i].Description__c, value: result[i].Category__c} ];
                }
            })
            .catch(error => {
                console.error("### call_getCadastralCategories Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    call_getCities() {
        console.log('### call_getCities');
        this.showSpinner = true;
        getCities({ })
            .then(result => {
                console.log('### result -> getCities', JSON.stringify(result));
                this.cityTechnicalData = result;
                for (var i = 0; i < result.length; i++) {
                    this.cityOptions=[...this.cityOptions,{label: result[i].CadastralCity__c , value: result[i].CadastralCity__c} ];
                }
            })
            .catch(error => {
                console.error("### call_getCities Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
    
    throwSuccessEvent(){
        const evt = new CustomEvent("formsuccess", { detail:  {rowId: this._recordId} });
        this.dispatchEvent(evt);
    }
    
    throwDeletionEvent(){
        const evt = new CustomEvent("deletion", { detail:  {rowId: this._recordId} });
        this.dispatchEvent(evt);
    }

    getFieldLoaded(all, key){
        if(!all) return this.this.fieldsCmpLoaded[key];
    }

    setFieldLoaded(all, value, key){
        if(all){
            Object.keys(this.fieldsCmpLoaded).forEach(key => {
                this.fieldsCmpLoaded[key] = value;
            });
        }
        else this.fieldsCmpLoaded[key] = value;
    }
}