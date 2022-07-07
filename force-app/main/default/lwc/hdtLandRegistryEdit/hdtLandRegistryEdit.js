import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
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
            this._recordId = newValue;
            this.setFieldLoaded(true, false);
        }
    }
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

    cadastralCategories = [];
    cityTechnicalData = [];
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
        this._required = this.required == false ? false : true;
        this._readonly = this.readonly;
        this._showEdit = this.showEdit;
        this._showDelete = this.showDelete;
    }

    handleFieldChange(event) {
        console.log("### handleFieldChange", event.target.name, event.target.fieldName);
        const source = event.target.name ? event.target.name : event.target.fieldName;
        if(this.getFieldLoaded(false, source)){
            this.disableSalva=false;
            if(source == "CodeMissingRegistryData__c") {
                if(event.detail.value == "") this._required = this.required == false ? false : true;
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
                if(curLength>3) {
                    const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Sezione Urbana 3 Caratteri' });
                    this.dispatchEvent(evt);
                    this.disableSalva=true;
                } 
                else this.disableSalva=false;
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
        this.modify = true;
    }

    handleEliminaClick(){
        let recordId = this._recordId;
        this._recordId = null;
        deleteRecord(recordId)
            .then(() => { this.throwDeletionEvent() })
            .catch(error => { console.error("### handleEliminaClick Errore", error) });
    }

    handleFormLoad(event){
        console.log("### handleFormLoad", JSON.stringify(event.detail.records));
        if(this._recordId){
            if(event.detail.records[this._recordId]){
                this.disableElimina = false;
                this.registryCityValue = event.detail.records[this._recordId].fields.RegistryCity__c.value;
                this.registryCityCodeValue = event.detail.records[this._recordId].fields.RegistryCityCode__c.value;
                this.legalCityValue = event.detail.records[this._recordId].fields.LegalCity__c.value;
                this.provinceValue = event.detail.records[this._recordId].fields.Province__c.value;
                this.cadastralCategoryValue = event.detail.records[this._recordId].fields.RegistryCategory__c.value;
            }
        }
        else{
            this.setFieldLoaded(true, true); // => non aspetto il change dei campi perchè saranno vuoti dato che è nuovo
            this.disableElimina = true;
            this.registryCityValue = null;
            this.registryCityCodeValue = null;
            this.legalCityValue = null;
            this.provinceValue = null;
            this.cadastralCategoryValue = null;
        }
        if(this.firstLoad){
            this.setFieldLoaded(true, true);
            this.firstLoad = false;
        }
        if(!this.showEdit) this.modify = true;
        let inputList = this.template.querySelectorAll('lightning-input-field');
        inputList.forEach(input => { 
            if( "CodeMissingRegistryData__c" == input.fieldName ) 
                if([ null, "" ].includes(input.value)) this._required = this.required == false ? false : true;
                else this._required = false;
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
        this.showSpinner = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleFormError(event){
        console.error("### handleFormError", event);
        const evt = new ShowToastEvent({ variant: 'error', title: 'Operazione non eseguita!', message: 'Errore ' + this._recordId });
        this.dispatchEvent(evt);
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
        let loaded = true;
        if(!all) loaded = this.fieldsCmpLoaded[key];
        else{
            Object.keys(this.fieldsCmpLoaded).forEach(key => {
                if(!this.fieldsCmpLoaded[key]) loaded = false;
            });
        }
        return loaded;
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