import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LNDRGS_OBJ from '@salesforce/schema/LandRegistry__c';
import retrieveLandRegistry from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistry';
import getCadastralCategories from '@salesforce/apex/HDT_UTL_LandRegistry.getCadastralCategories';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';

const RT_NAME = 'Dati Catastali TARI';
const COLUMNS = [
    { label: 'Nome Record',                     fieldName: 'Name',                                      type: 'text' },
    // { label: 'Codice assenza dati catastali',   fieldName: 'CodeMissingRegistryData__c',                type: 'text' },
    // { label: 'Destinazione Uso',                fieldName: 'DestinationUsage__c',                       type: 'text' },
    { label: 'Comune catastale',                fieldName: 'RegistryCity__c',                           type: 'text' },
    // { label: 'Codice comune catastale',         fieldName: 'RegistryCityCode__c',                       type: 'text' },
    // { label: 'Comune amministrativo',           fieldName: 'LegalCity__c',                              type: 'text' },
    { label: 'Provincia ubicazione',            fieldName: 'Province__c',                               type: 'text' },
    // { label: 'Tipo unita',                      fieldName: 'UnitType__c',                               type: 'text' },
    { label: 'Sezione urbana',                  fieldName: 'UrbanSection__c',                           type: 'text' },
    { label: 'Foglio',                          fieldName: 'Sheet__c',                                  type: 'text' },
    { label: 'Particella',                      fieldName: 'ParticleSheet__c',                          type: 'text' },
    { label: 'Subalterno',                      fieldName: 'Subaltern__c',                              type: 'text' },
    // { label: 'Categoria Catastale',             fieldName: 'RegistryCategory__c',                       type: 'text' },
    { label: 'Superficie Catastale',            fieldName: 'RegistrySurface__c',                        type: 'text' },
    // { label: 'Qualifica Titolare',              fieldName: 'Title__c',                                  type: 'text' }
];

export default class HdtLandRegistry extends LightningElement {
    @wire(getObjectInfo, { objectApiName: LNDRGS_OBJ })
    objectInfo;
    
    @api servicePointId;                //inputOnly
    @api preSelectedLandRegistryId;     //inputOnly
    @api required;                      //inputOnly
    @api readonly;                      //inputOnly
    @api selectedLandRegistryId;        //outputOnly

    @track tableData = [];
    @track tableSelectedRows = [];
    @track tableColumns = COLUMNS;

    get rtIdTari(){
        let rtId;
        if(this.objectInfo.data){
            const recordTypesMap = this.objectInfo.data.recordTypeInfos;
            const foundRt = Object.values(recordTypesMap).find( element => element.name === RT_NAME );
            if(foundRt) rtId = foundRt.recordTypeId;
        }
        return rtId;
    }
    get disableModifica(){ return !this.selectedLandRegistryId || this.selectedLandRegistryId == '' || this._readonly }
    disableSalva = false;
    disableForm = true;

    showSpinner = false;
    showSalva = false;
    showTable=false;
    showForm=false;

    cadastralCategories = [];
    cityTechnicalData = [];
    cadastralCategoryOptions = [];
    cityOptions = [];
    
    registryCityValue;
    legalCityValue;
    registryCityCodeValue;
    provinceValue;
    cadastralCategoryValue;

    _required;
    _readonly;

    connectedCallback(){
        this.required=true;                                     //MOCKATO PER TEST (da togliere)
        this.servicePointId = 'a281X000000DqcVQAS';             //MOCKATO PER TEST (da togliere)
        console.log('### connectedCallback selectedLandRegistryId', this.selectedLandRegistryId);
        this.call_retrieveLandRegistry();
        this.call_getCadastralCategories();
        this.call_getCities();
        this._required = this.required;
        this._readonly = this.readonly;
        this.selectedLandRegistryId = this.preSelectedLandRegistryId;
    }

    call_retrieveLandRegistry() {
        console.log('### call_retrieveLandRegistry');
        this.showTable=false;
        this.showForm=false;
        this.showSpinner = true;
        this.disableForm=true;
        this.showSalva=false;
        retrieveLandRegistry({ servicePointIds : this.servicePointId })
            .then(result => {
                console.log('### result', JSON.stringify(result));
                this.tableData = result;
            })
            .catch(error => {
                console.error("### retrieveLandRegistry Errore", error);
            })
            .finally(() => {
                if(this.tableData.length > 0){
                    if(this.selectedLandRegistryId) this.tableSelectedRows = [this.selectedLandRegistryId];
                    if(this.tableSelectedRows.length == 0 ) this.tableSelectedRows = [this.tableData[0].Id];
                    this.handleSelection(this.tableSelectedRows[0]);
                    this.showTable=true;
                    this.showForm=true;
                    this.throwSelectionEvent();
                }
                this.showSpinner = false;
            });
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
                console.error("### retrieveLandRegistry Errore", error);
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
                console.error("### retrieveLandRegistry Errore", error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleFieldChange(event) {
        console.log("### handleFieldChange", event);
        this.disableSalva=false;
        const source = event.target.name ? event.target.name : event.target.fieldName;
        console.log("### handleFieldChange source", source);
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

    handleTableSelection(event){
        this.showForm=false;
        this.selectedLandRegistryId = event.detail.selectedRows[0].Id;
        this.showSalva=false;
        this.disableForm=true;
        this.showForm=true;
        this.handleSelection(event.detail.selectedRows[0].Id);
        this.throwSelectionEvent();
    }

    handleSelection(rowId){
        const selectedRow = this.tableData.find(element => element.Id == rowId);
        if(selectedRow){
            this.registryCityValue = selectedRow.RegistryCity__c;
            this.registryCityCodeValue = selectedRow.RegistryCityCode__c;
            this.legalCityValue = selectedRow.LegalCity__c;
            this.provinceValue = selectedRow.Province__c;
            this.cadastralCategoryValue = selectedRow.RegistryCategory__c;
        }
        else{
            this.registryCityValue = null;
            this.registryCityCodeValue = null;
            this.legalCityValue = null;
            this.provinceValue = null;
            this.cadastralCategoryValue = null;
        }
    }

    handleModificaClick(){
        this.disableSalva=false;
        this.showSalva=true;
        this.disableForm=false;
    }

    handleNuovoClick(){
        // this.showForm=false;
        this.selectedLandRegistryId='';
        this.disableForm=false;
        this.showForm=true;
        this.disableSalva=false;
        this.showSalva=true;
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
        this.showSpinner = true;
    }

    handleFormSuccess(event){
        console.log("### handleFormSuccess", JSON.stringify(event.detail));
        this.selectedLandRegistryId=event.detail.id;
        this.call_retrieveLandRegistry();
        const evt = new ShowToastEvent({ variant: 'success', title: 'Operazione eseguita correttamente!', message: 'Record salvato.' });
        this.dispatchEvent(evt);
    }

    handleFormError(event){
        console.error("### handleFormError", event);
        this.showSpinner = false;
    }

    throwSelectionEvent(){
        const evt = new CustomEvent("onselection", { detail:  {rowId: this.selectedLandRegistryId} });
        this.dispatchEvent(evt);
    }
    
}