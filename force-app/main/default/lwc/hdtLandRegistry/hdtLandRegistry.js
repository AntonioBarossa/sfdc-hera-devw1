import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import retrieveLandRegistryTable from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistryTable';

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
    
    @api orderId;                       //inputOnly
    @api caseId;                        //inputOnly
    @api servicePointId;                //inputOnly
    @api preSelectedLandRegistryId;     //inputOnly
    @api required;                      //inputOnly
    @api readonly;                      //inputOnly
    @api selectedLandRegistryId;        //outputOnly

    @track tableData = [];
    @track tableSelectedRows = [];
    @track tableColumns = COLUMNS;

    // showTable=false;
    showSpinner = false;

    _required;
    _readonly;
    @track _selectedLandRegistryId;

    connectedCallback(){
        //this.required=true;                                     //MOCKATO PER TEST (da togliere)
        //this.servicePointId = 'a281X000000DqcVQAS';             //MOCKATO PER TEST (da togliere)
        console.log('### connectedCallback preSelectedLandRegistryId', this.preSelectedLandRegistryId);
        this.call_retrieveLandRegistryTable();
        this._required = this.required;
        this._readonly = this.readonly;
        this._selectedLandRegistryId = this.preSelectedLandRegistryId;
        this.selectedLandRegistryId = this.preSelectedLandRegistryId;
    }

    call_retrieveLandRegistryTable() {
        console.log('### call_retrieveLandRegistryTable');
        this.showTable=false;
        this.showSpinner = true;
        retrieveLandRegistryTable({ caseId: this.caseId, orderId: this.orderId, servicePointId: this.servicePointId })
            .then(result => {
                console.log('### result', JSON.stringify(result));
                this.tableData = result;
            })
            .catch(error => {
                console.error("### retrieveLandRegistry Errore", error);
            })
            .finally(() => {
                if(this.tableData.length > 0){
                    if(!this._selectedLandRegistryId){
                        this.selectedLandRegistryId = this.tableData[0].Id;
                        this._selectedLandRegistryId = this.tableData[0].Id;
                    }
                    this.tableSelectedRows = [this._selectedLandRegistryId];
                    this.showTable=true;
                    this.throwSelectionEvent();
                }
                else{
                    this.selectedLandRegistryId = null;
                    this._selectedLandRegistryId = null;
                }
                this.showSpinner = false;
            });
    }

    handleTableSelection(event){
        this.selectedLandRegistryId = event.detail.selectedRows[0].Id;
        this._selectedLandRegistryId = event.detail.selectedRows[0].Id;
        this.throwSelectionEvent();
    }

    handleNuovoClick(){
        this.selectedLandRegistryId = null;
        this._selectedLandRegistryId = null;
        this.tableSelectedRows = [];
    }

    handleEditSave(event){
        this.selectedLandRegistryId = event.detail.rowId;
        this._selectedLandRegistryId = event.detail.rowId;
        this.call_retrieveLandRegistryTable();
    }
    
    handleEditDeletion(){
        // this.selectedLandRegistryId = null;
        // this._selectedLandRegistryId = null;
        this.call_retrieveLandRegistryTable();
    }

    throwSelectionEvent(){
        const evt = new CustomEvent("selection", { detail:  {rowId: this._selectedLandRegistryId} });
        this.dispatchEvent(evt);
    }
    
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}