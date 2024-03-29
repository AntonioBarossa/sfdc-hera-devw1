import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import retrieveLandRegistryTable from '@salesforce/apex/HDT_UTL_LandRegistry.retrieveLandRegistryTable';

const COLUMNS = [
    { label: 'Nome Record',                     fieldName: 'Name',                                      type: 'text' },
    // { label: 'Codice assenza dati catastali',   fieldName: 'CodeMissingRegistryData__c',                type: 'text' },
    { label: 'Destinazione Uso',                fieldName: 'DestinationUsage__c',                       type: 'text' },
    { label: 'Comune catastale',                fieldName: 'RegistryCity__c',                           type: 'text' },
    { label: 'Codice comune catastale',         fieldName: 'RegistryCityCode__c',                       type: 'text' },
    // { label: 'Comune amministrativo',           fieldName: 'LegalCity__c',                              type: 'text' },
    // { label: 'Provincia ubicazione',            fieldName: 'Province__c',                               type: 'text' },
    // { label: 'Tipo unita',                      fieldName: 'UnitType__c',                               type: 'text' },
    // { label: 'Sezione urbana',                  fieldName: 'UrbanSection__c',                           type: 'text' },
    { label: 'Foglio',                          fieldName: 'Sheet__c',                                  type: 'text' },
    { label: 'Particella',                      fieldName: 'ParticleSheet__c',                          type: 'text' },
    { label: 'Subalterno',                      fieldName: 'Subaltern__c',                              type: 'text' },
    // { label: 'Categoria Catastale',             fieldName: 'RegistryCategory__c',                       type: 'text' },
    // { label: 'Superficie Catastale',            fieldName: 'RegistrySurface__c',                        type: 'text' },
    { label: 'Qualifica Titolare',              fieldName: 'Title__c',                                  type: 'text' }
];

export default class HdtLandRegistry extends LightningElement {
    
    @api orderId;                       //inputOnly
    @api caseId;                        //inputOnly
    @api servicePointId;                //inputOnly
    @api preSelectedLandRegistryId;     //inputOnly
    @api required;                      //inputOnly
    @api readonly;                      //inputOnly
    @api selectedLandRegistryId;        //outputOnly
    @api sessionid;
    
    @api validate (){
        let isValid = this.tableData?.length != 0;
        let msg = isValid? null : 'Inserire almeno un dato catastale.';
        if(!isValid)    return { isValid : isValid, errorMessage: msg };

        const form = this.template.querySelector("c-hdt-land-registry-edit");
        isValid &&= !form.validateForm();
        console.log('isValid '+isValid);

        //cache
        if(this.sessionid){
            if(!isValid){
                window.sessionStorage.setItem(this.sessionid, this.selectedLandRegistryId);
            }else{
                window.sessionStorage.removeItem(this.sessionid);
            }
        }
        //cache
        
        const validation = { isValid : isValid,
                errorMessage: isValid? null : "Valorizzare i campi obbligatori" 
        };
        return validation;
    }

    @track tableData = [];
    @track tableSelectedRows = [];
    @track tableColumns = COLUMNS;
    @track _selectedLandRegistryId;

    _tableSelectedRowsHidden;

    // showTable=false;
    showSpinner = false;

    _required;
    _readonly;

    isEditing = false;

    _showLandRegistryEdit = false;

    get tableDataFiltered(){
        return this.tableData.filter(el=>el.Id===this._selectedLandRegistryId);
    }

    get tableDataLength(){
        return this.tableData?.length;
    }

    connectedCallback(){
        //this.required=true;                                     //MOCKATO PER TEST (da togliere)
        //this.servicePointId = 'a281X000000DqcVQAS';             //MOCKATO PER TEST (da togliere)
        console.log('### connectedCallback preSelectedLandRegistryId', this.preSelectedLandRegistryId);
        this.call_retrieveLandRegistryTable();
        //cache
        const overridePreselected = window.sessionStorage.getItem(this.sessionid);
        window.sessionStorage.removeItem(this.sessionid);
        //cache
        this._required = this.required;
        this._readonly = this.readonly;
        this._selectedLandRegistryId = overridePreselected? overridePreselected :  this.preSelectedLandRegistryId;
        this.selectedLandRegistryId = overridePreselected? overridePreselected :  this.preSelectedLandRegistryId;
    }

    handleEdit(event){
        this.isEditing = event.detail.isEditing;
        if(event.detail.restoredId){
            this.tableSelectedRows=[event.detail.restoredId];
            this._selectedLandRegistryId = event.detail.restoredId;
        }
        this._readonly = event.detail.isEditing && !this.readonly;
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
                    this._showLandRegistryEdit = true;
                    if(!this._selectedLandRegistryId){
                        this.selectedLandRegistryId = this.tableData[0].Id;
                        this._selectedLandRegistryId = this.tableData[0].Id;
                    }
                    this.tableSelectedRows = [this._selectedLandRegistryId];
                    this.showTable=true;
                    this.throwSelectionEvent();
                }
                else{
                    this._showLandRegistryEdit = false;
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
        this._showLandRegistryEdit = true;
        this.isEditing = true;
        this._readonly = true;
    }

    handleEditSave(event){
        this.selectedLandRegistryId = event.detail.rowId;
        this._selectedLandRegistryId = event.detail.rowId;
        this.call_retrieveLandRegistryTable();
        this._readonly = false;
    }
    
    handleEditDeletion(){
        this.selectedLandRegistryId = null;
        this._selectedLandRegistryId = null;
        this.call_retrieveLandRegistryTable();
        this.isEditing = false;
        this._readonly = false;
    }

    throwSelectionEvent(){
        const evt = new CustomEvent("selection", { detail:  {rowId: this._selectedLandRegistryId} });
        this.dispatchEvent(evt);
    }
    
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}