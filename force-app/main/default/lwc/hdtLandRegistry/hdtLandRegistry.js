import { LightningElement } from 'lwc';

export default class HdtLandRegistry extends LightningElement {
    
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
        this.required=true;                                     //MOCKATO PER TEST (da togliere)
        this.servicePointId = 'a281X000000DqcVQAS';             //MOCKATO PER TEST (da togliere)
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
        retrieveLandRegistryTable({ servicePointIds : this.servicePointId })
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