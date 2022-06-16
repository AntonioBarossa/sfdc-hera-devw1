import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveLandRegistry from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistry';
import getCadastralCategories from '@salesforce/apex/HDT_UTL_LandRegistry.getCadastralCategories';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';


const columns = [
    { label: 'Codice assenza dati catastali',   fieldName: 'CodeMissingRegistryData__c',                type: 'text' },
    { label: 'Destinazione Uso',                fieldName: 'DestinationUsage__c',                       type: 'text' },
    { label: 'Comune catastale',                fieldName: 'RegistryCity__c',                           type: 'text' },
    { label: 'Codice comune catastale',         fieldName: 'RegistryCityCode__c',                       type: 'text' },
    { label: 'Comune amministrativo',           fieldName: 'LegalCity__c',                              type: 'text' },
    { label: 'Provincia ubicazione',            fieldName: 'Province__c',                               type: 'text' },
    { label: 'Tipo unita',                      fieldName: 'UnitType__c',                               type: 'text' },
    { label: 'Sezione urbana',                  fieldName: 'UrbanSection__c',                           type: 'text' },
    { label: 'Foglio',                          fieldName: 'Sheet__c',                                  type: 'text' },
    { label: 'Particella',                      fieldName: 'ParticleSheet__c',                          type: 'text' },
    { label: 'Subalterno',                      fieldName: 'Subaltern__c',                              type: 'text' },
    { label: 'Categoria Catastale',             fieldName: 'RegistryCategory__c',                       type: 'text' },
    { label: 'Superficie Catastale',            fieldName: 'RegistrySurface__c',                        type: 'text' },
    { label: 'Qualifica Titolare',              fieldName: 'Title__c',                                  type: 'text' },
    { label: 'Punto di fornitura',              fieldName: 'ServicePoint__r.ServicePointCode__c',       type: 'text' }   
];

export default class HdtLandRegistry extends LightningElement {
    
    @api servicePointId = 'a281X000000DqcVQAS'; //ID MOCKATO PER TEST (da togliere)
    @api selectedLandRegistryId = 'a3j1x000000Fa14AAC'; //ID MOCKATO PER TEST (da togliere)
    @api required = false;
    @api readonly = false;

    @track tableData = [];
    @track tableSelectedRows = [];
    @track tableColumns=columns;
    @track registryCityValue;
    @track legalCityValue;
    @track registryCityCodeValue;
    @track provinceValue;
    @track cadastralCategoryValue;

    get disableModifica(){ return !this.selectedLandRegistryId || this.selectedLandRegistryId=='' || this.readonly }
    disableSalva=false;
    disableForm=true;

    showSpinner=false;
    showSalva=false;
    // showTable=false;
    // showForm=false;

    cadastralCategories = [];
    cityTechnicalData = [];
    cadastralCategoryOptions = [];
    cityOptions = [];

    connectedCallback(){
        console.log('### connectedCallback');
        console.log('### selectedLandRegistryId= '+this.selectedLandRegistryId);
        this.call_retrieveLandRegistry();
        this.call_getCadastralCategories();
        this.call_getCities();
    }

    call_retrieveLandRegistry() {
        console.log('### call_retrieveLandRegistry');
        if(this.selectedLandRegistryId) this.tableSelectedRows = [this.selectedLandRegistryId];
        // this.showTable=false;
        // this.showForm=false;
        this.showSpinner = true;
        this.disableForm=true;
        this.showSalva=false;
        retrieveLandRegistry({ servicePointIds : this.servicePointId })
            .then(result => {
                console.log('### result', JSON.stringify(result));
                this.tableData = result;
            })
            .catch(error => {
                console.error("### retrieveLandRegistry Errore: "+error);
            })
            .finally(() => {
                if(this.tableData.length > 0){
                    if(this.tableSelectedRows.length == 0 ) this.tableSelectedRows = [this.tableData[0].Id];
                    this.handleSelection(this.tableSelectedRows[0]);
                    // this.showTable=true;
                    // this.showForm=true;
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
                console.log('### cadastralCategories', this.cadastralCategoryOptions);
            })
            .catch(error => {
                console.error("### getCadastralCategories Errore: "+error);
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
                console.log('### cityOptions', this.cityOptions);
            })
            .catch(error => {
                console.error("### getCities Errore: "+error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleFieldChange(event) {
        console.log("### handleFieldChange", event);
        this.disableSalva=false;
        const source = event.target.name ? event.target.name : event.target.fieldName;
        if(source == "RegistryCity__c"){
            let foundCity = this.cityTechnicalData.find(element => element.CadastralCity__c == event.detail.value);
            this.registryCityValue = foundCity.CadastralCity__c;
            this.legalCityValue = foundCity.CadastralCity__c;
            this.registryCityCodeValue = foundCity.CityCode__c;
            this.provinceValue = foundCity.Province__c;
        }
        if(source == "Subaltern__c") {
            const curLength = event.target.value.length;
            if(curLength<=4) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Subalterno 4 Caratteri' });
                this.dispatchEvent(evt);
                this.disableSalva=true;
            }
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
        if(source == "ParticleSheet__c") {
            const curLength = event.target.value.length;
            if(curLength<=5) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Particella 5 caratteri' });
                this.dispatchEvent(evt);
                this.disableSalva=true;
            }
        }
        if(source == "Sheet__c") {
            const curLength = event.target.value.length;
            if(curLength<=4) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Foglio 4 caratteri' });
                this.dispatchEvent(evt);
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
        // this.showForm=false;
        this.selectedLandRegistryId = event.detail.selectedRows[0].Id;
        this.showSalva=false;
        this.disableForm=true;
        // this.showForm=true;
        this.handleSelection(event.detail.selectedRows[0].Id);
        this.throwSelectionEvent();
    }

    handleSelection(rowId){
        const selectedRow = this.tableData.find(element => element.Id == rowId);
        this.registryCityValue = selectedRow.RegistryCity__c;
        this.registryCityCodeValue = selectedRow.RegistryCityCode__c;
        this.legalCityValue = selectedRow.LegalCity__c;
        this.provinceValue = selectedRow.Province__c;
        this.cadastralCategoryValue = selectedRow.RegistryCategory__c;
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
        // this.showForm=true;
        this.disableSalva=false;
        this.showSalva=true;
    }

    handleFormSubmit(event){
        console.log("### handleFormSubmit1", JSON.stringify(event.detail.fields));
        event.preventDefault();
        event.detail.fields.RegistryCity__c = this.registryCityValue;
        event.detail.fields.LegalCity__c = this.legalCityValue;
        event.detail.fields.RegistryCategory__c = this.cadastralCategoryValue;
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