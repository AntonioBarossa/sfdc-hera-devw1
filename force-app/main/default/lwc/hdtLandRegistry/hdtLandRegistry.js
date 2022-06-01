import { LightningElement, api, track } from 'lwc';
import retrieveLandRegistry from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistry';
import getCadastralCategories from '@salesforce/apex/HDT_UTL_LandRegistry.getCadastralCategories';
import getCities from '@salesforce/apex/HDT_UTL_LandRegistry.getCities';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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
    
    @api servicePointId = 'a281X000000DmNZQA0'; //ID MOCKATO PER TEST (da togliere)
    @api selectedLandRegistryId = 'a3j1w000000VlZDAA0'; //ID MOCKATO PER TEST (da togliere)
    @api required = false;
    @api readonly = false;

    @track tableData = [];
    @track tableData2 = [];
    @track tableData3 = [];

    @track tableSelectedRows = [];
    @track tableColumns=columns;

    valueRegistryCity = '';
    valueRegistryCategory = '';

    get RegistryCityOptions() {
        return [
            { label: 'Milano',      value: 'Milano' },
            { label: 'Roma',        value: 'Roma' },
            { label: 'Rieti',       value: 'Rieti' },
            { label: 'Rimini',      value: 'Rimini' }
        ];
    }

    RegistryCategoryOptions = [];

    get disableModifica(){ return !this.selectedLandRegistryId || this.selectedLandRegistryId=='' || this.readonly }
    disableSalva=false;
    disableForm=true;

    showSpinner=false;
    showSalva=false;
    showTable=false;
    showForm=false;
    
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
        this.showTable=false;
        this.showForm=false;
        this.showSpinner = true;
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
                    this.showTable=true;
                    this.showForm=true;
                    this.throwSelectionEvent();
                }
                this.showSpinner = false;
            });
    }

    // Cadastral Categories
    call_getCadastralCategories() {
        console.log('### call_getCadastralCategories');
        //if(this.selectedLandRegistryId) this.tableSelectedRows = [this.selectedLandRegistryId];
        this.showTable=false;
        this.showForm=false;
        this.showSpinner = true;
        getCadastralCategories({ })
            .then(result => {
                console.log('### result -> getCadastralCategories', JSON.stringify(result));
                //this.tableData2 = result;
                for (var i = 0; i < result.length; i++) {
                    this.RegistryCategoryOptions=[...this.RegistryCategoryOptions,{label: result[i].Categoria__c , value: result[i].Categoria__c} ];
                }
                console.log('### RegistryCategoryOptions', RegistryCategoryOptions);
            })
            .catch(error => {
                console.error("### getCadastralCategories Errore: "+error);
            })
            .finally(() => {
                if(this.tableData2.length > 0){
                    if(this.tableSelectedRows.length == 0 ) this.tableSelectedRows = [this.tableData2[0].Id];
                    this.showTable=true;
                    this.showForm=true;
                    this.throwSelectionEvent();
                }
                this.showSpinner = false;
            });
    }

    // Cities
    call_getCities() {
        console.log('### call_getCities');
        //if(this.selectedLandRegistryId) this.tableSelectedRows = [this.selectedLandRegistryId];
        this.showTable=false;
        this.showForm=false;
        this.showSpinner = true;
        getCities({ })
            .then(result => {
                console.log('### result -> getCities', JSON.stringify(result));
                this.tableData3 = result;
            });
            // .catch(error => {
            //     console.error("### getCadastralCategories Errore: "+error);
            // })
            // .finally(() => {
            //     if(this.tableData3.length > 0){
            //         if(this.tableSelectedRows.length == 0 ) this.tableSelectedRows = [this.tableData3[0].Id];
            //         this.showTable=true;
            //         this.showForm=true;
            //         this.throwSelectionEvent();
            //     }
            //     this.showSpinner = false;
            // });
    }

    // Combobox
    handleRegistryCity(event) {
        console.log("### handleRegistryCity", event);
        console.log("### event.target.Name ", event.target.Name);
        console.log("### event.target.fieldName ", event.target.fieldName);
        console.log("### event.detail.value ", event.detail.value);
        console.log("### event.detail.label ", event.detail.label);

        this.valueRegistryCity = event.detail.value;

        //this.valueRegistryCity = event.detail.RegistryCity__c;
        if(event.target.Name == 'RegistryCity') {
            console.log("### event.target.fieldName ", event.target.fieldName);
            console.log("### event.detail.value ", event.detail.value);

            this.valueRegistryCity = event.detail.value;
            console.log("### valueRegistryCity ", valueRegistryCity);
        }

        //var temp = this.template.querySelector("lightning-combobox[name='RegistryCity']").value;

        
    }

    handleTableSelection(event){
        this.showForm=false;
        this.selectedLandRegistryId = event.detail.selectedRows[0].Id;
        this.showSalva=false;
        this.disableForm=true;
        this.showForm=true;
        this.throwSelectionEvent();
    }

    handleModificaClick(){
        this.disableSalva=false;
        this.showSalva=true;
        this.disableForm=false;
    }

    handleNuovoClick(){
        this.showForm=false;
        this.selectedLandRegistryId='';
        this.disableForm=false;
        this.showForm=true;
        this.disableSalva=false;
        this.showSalva=true;
    }

    handleFormSubmit(event){
        console.log("### handleFormSubmit", event);
        this.disableSalva=true;
        this.showSpinner = true;
    }

    handleFormSuccess(event){
        console.log("### handleFormSuccess", event);
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

    maxLength(event) {
        console.log('### entered to maxLength');
        this.disableSalva=true;

        // Controllo Foglio
        if(event.target.fieldName == "Sheet__c") {
            console.log('### event.target.fieldName= ', event.target.fieldName);
            const temp = event.target.value.length;
            console.log('### temp ', temp);
            if(temp<=4) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Foglio 4 caratteri' });
                this.dispatchEvent(evt);
            }
        }

        // Controllo Particella
        if(event.target.fieldName == "ParticleSheet__c") {
            console.log('### event.target.fieldName= ', event.target.fieldName);
            const temp = event.target.value.length;
            console.log('### temp ', temp);
            if(temp<=5) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Particella 5 caratteri' });
                this.dispatchEvent(evt);
            }
        }

        // Controllo Sezione Urbana
        if(event.target.fieldName == "UrbanSection__c") {
            console.log('### event.target.fieldName= ', event.target.fieldName);
            const temp = event.target.value.length;
            console.log('### temp ', temp);
            if(temp<=3) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Sezione Urbana 3 Caratteri' });
                this.dispatchEvent(evt);
            }
        }

        // Controllo Subalterno
        if(event.target.fieldName == "Subaltern__c") {
            console.log('### event.target.fieldName= ', event.target.fieldName);
            const temp = event.target.value.length;
            console.log('### temp ', temp);
            if(temp<=4) {
                 this.disableSalva=false;
            } else {
                const evt = new ShowToastEvent({ variant: 'error', title: 'Attenzione!', message: 'Lunghezza massima Subalterno 4 Caratteri' });
                this.dispatchEvent(evt);
            }
        }

    }
    
}