import { LightningElement, api, track } from 'lwc';
import retrieveLandRegistry from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistry';

const columns = [
    { label: 'Codice assenza dati catastali',   fieldName: 'CodeMissingRegistryData__c',    type: 'text' },
    { label: 'Destinazione Uso',                fieldName: 'DestinationUsage__c',           type: 'text' },
    { label: 'Comune catastale',                fieldName: 'RegistryCity__c',               type: 'text' },
    { label: 'Codice comune catastale',         fieldName: 'RegistryCityCode__c',           type: 'text' },
    { label: 'Comune amministrativo',           fieldName: 'LegalCity__c',                  type: 'text' },
    { label: 'Provincia ubicazione',            fieldName: 'Province__c',                   type: 'text' },
    { label: 'Tipo unita',                      fieldName: 'UnitType__c',                   type: 'text' },
    { label: 'Sezione urbana',                  fieldName: 'UrbanSection__c',               type: 'text' },
    { label: 'Foglio',                          fieldName: 'Sheet__c',                      type: 'text' },
    { label: 'Particella',                      fieldName: 'ParticleSheet__c',              type: 'text' },
    { label: 'Subalterno',                      fieldName: 'Subaltern__c',                  type: 'text' },
    { label: 'Categoria Catastale',             fieldName: 'RegistryCategory__c',           type: 'text' },
    { label: 'Superficie Catastale',            fieldName: 'RegistrySurface__c',            type: 'text' },
    { label: 'Qualifica Titolare',              fieldName: 'Title__c',                      type: 'text' }   
];

export default class HdtLandRegistry extends LightningElement {
    
    @api servicePointId = 'a281X000000DmNZQA0'; //ID MOCKATO PER TEST (da togliere)
    @api selectedLandRegistryId = 'a3j1w000000VlZDAA0';
    @api required = false;
    @api readonly = false;

    @track tableData = [];
    @track tableSelectedRows = [];
    @track tableColumns=columns;

    disableSalva=false;
    disableModifica=false;
    disableNuovo=false;
    disableForm=true;

    showSpinner=false;
    showSalva=false;
    showTable=false;
    showForm=false;
    
    connectedCallback(){
        console.log('### connectedCallback');
        console.log('### selectedLandRegistryId= '+this.selectedLandRegistryId);
        console.log('### tableSelectedRows= '+this.tableSelectedRows);
        if(this.selectedLandRegistryId) this.tableSelectedRows.push(this.selectedLandRegistryId);
        console.log('### tableSelectedRows= '+this.tableSelectedRows);
        this.getRetrieveLandRegistry();
    }

    getRetrieveLandRegistry() {
        console.log('### getRetrieveLandRegistry');
        this.showSpinner = true;
        retrieveLandRegistry({ servicePointIds : this.servicePointId })
            .then(result => {
                console.log('### retrieveLandRegistry');
                console.log('### result', JSON.stringify(result));
                this.tableData = result;
                this.showSpinner = false;
                if(this.tableData.length == 0){
                    this.disableModifica=true;
                    this.showTable=false;
                    this.showForm=false;
                } 
                else{
                    if(this.tableSelectedRows.length == 0 ) this.tableSelectedRows.push(this.tableData[0].Id);
                    this.showTable=true;
                    this.showForm=true;
                }                 
            })
            .catch(error => {
                 console.log("### retrieveLandRegistry Errore: "+error);
            });
    }

    handleTableSelection(event){
        this.showForm=false;
        this.selectedLandRegistryId = event.detail.selectedRows[0].Id;
        this.showSalva=false;
        this.disableForm=true;
        this.showForm=true;
        this.trowSelectionEvent();
    }

    handleModificaClick(event){
        this.showSalva=true;
        this.disableForm=false;
    }

    handleNuovoClick(event){
        //TODO: creare nuovo oggetto riga vuota
        //TODO: assegnare id nuovo oggetto a selectedLandRegistryId
        //TODO: this.disableForm=false;
        //TODO: this.showSalva=true;
    }

    trowSelectionEvent(){
        const evt = new CustomEvent("onselection", {
            detail:  {rowId: this.selectedLandRegistryId}
        });
        this.dispatchEvent(evt);
    }

}