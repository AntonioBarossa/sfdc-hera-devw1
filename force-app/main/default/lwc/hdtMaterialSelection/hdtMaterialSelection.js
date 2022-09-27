import {LightningElement, wire, track, api} from 'lwc';

import getVolumetricEstimate from '@salesforce/apex/HDT_LC_MaterialSelection.getVolumetricEstimate';

const COLUMNS = [ 
        { label: 'Descrizione', fieldName: 'Description__c', hideDefaultActions: "true"},
        { label: 'Metri Cubi', fieldName: 'Cubic_Meters__c', hideDefaultActions: "true"},
        { label: 'Tipologia', fieldName: 'Typology__c', hideDefaultActions: "true"}
    ];

export default class HdtMaterialSelection extends LightningElement {

    @api caseId;
    @api cubatureLimit;
    @api flowSessionId;

    @track data;
    @track error;
    @track columns = COLUMNS;
    @track searchString;
    @track _initialRecords;
    @track _setGlobalSelectedIds= new Set();
    @track _globalSelectionMap = new Map();

    _reloadingTable;
    
    @track preSelectedKeys= [];
    @track selectedData=[];
    get isDataSelected(){
        return this.selectedData.length
    }

    showModal = false;
    doneTypingInterval = 500;
    typingTimer;
    // showSpinner = true;

    @wire(getVolumetricEstimate)
    contacts(result) {
        if (result.data) {
            this.data = result.data;
            this._initialRecords = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    connectedCallback(){
        
    }

    handleRowAction(event){
        let selectedRecords = event.detail.selectedRows;
        let isRemoval = this.preSelectedKeys.length > selectedRecords.length;

        let preselectedRowsMap = this.preSelectedKeys.reduce((result, key)=>{
            result.set(key, this._globalSelectionMap.get(key));
            return result;
        }, new Map());
        let selectedRecordsMap = selectedRecords.reduce((result, elem)=>{
            result.set(elem.Id, elem);
            return result;
        }, new Map());

        if(this._reloadingTable){
            this.preSelectedKeys = [...selectedRecordsMap.keys()];
            this._reloadingTable=false;
        }
        else{
            this.selectedData=[];
            console.log('selectedRecords are ', selectedRecords);

            let mapToCompare = isRemoval? selectedRecordsMap : preselectedRowsMap;

            let mapToForeach = isRemoval? preselectedRowsMap : selectedRecordsMap;

            mapToForeach.forEach((currentItem, key)=>{
                if(!mapToCompare.has(currentItem.Id) && isRemoval){
                    this._globalSelectionMap.delete(currentItem.Id);
                }else{
                    this._globalSelectionMap.set(currentItem.Id, currentItem);
                }
            });
            
            this.selectedData=[...this._globalSelectionMap.values()];
            console.log('selectedData are ', this.selectedData);
            this.preSelectedKeys = [...selectedRecordsMap.keys()];
            
        }
        
    }

    showMessage(title, message, variant, mode) {
        //Create Toast Message
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(toastErrorMessage);
    }

    openModal(){
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
    }
        
    addRecord(element){
        this.selectedData = [...this.selectedData,element];
    }

    onchangeSearch(event){
        clearTimeout(this.typingTimer);
        let value = event.target.value;
        this.typingTimer = setTimeout(() => {
            if(value){
                this.filterData(value);
            }else{
                console.log('******** Debounce Restore Initial:');
                this.data = this._initialRecords;
                this.preSelectedKeys = [...this._globalSelectionMap.keys()];
                //this.preSelectedKeys = [...this._setGlobalSelectedIds];
            }
        }, this.doneTypingInterval);
    }

    filterData(value){
        console.log('******** Search Debounced Text:' + value);

            const searchKey = value.toLowerCase();
     
            if (searchKey) {
                this.data = this._initialRecords;
     
                if (this.data) {
                    this.preSelectedKeys = [];
                    let searchRecords = [];
     
                    for (let record of this.data) {
                        let valuesArray = Object.values(record);
     
                        for (let val of valuesArray) {
                            console.log('val is ' + val);
                            let strVal = String(val);
     
                            if (strVal) {
                                if (strVal.toLowerCase().includes(searchKey)) {
                                    if(this._globalSelectionMap.has(record.Id)) this.preSelectedKeys.push(record.Id);
                                    searchRecords.push(record);
                                    break;
                                }
                            }
                        }
                    }
     
                    this._reloadingTable=this.preSelectedKeys.length;
                    this.data = searchRecords;
                }
            } 
    }

}