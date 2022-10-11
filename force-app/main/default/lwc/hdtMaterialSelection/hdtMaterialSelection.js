import {LightningElement, wire, track, api} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTables from '@salesforce/apex/HDT_LC_MaterialSelection.getTables';
import createJunctionObj from '@salesforce/apex/HDT_LC_MaterialSelection.createJunctionObj';

const COLUMNS = [ 
        { label: 'Descrizione', fieldName: 'Description__c', hideDefaultActions: "true"},
        { label: 'Metri Cubi', fieldName: 'CubicMeters__c', hideDefaultActions: "true"},
        { label: 'Tipologia', fieldName: 'Typology__c', hideDefaultActions: "true"}
    ];

export default class HdtMaterialSelection extends LightningElement {

    @api caseId;
    @api isCubatureLimited;
    @api flowSessionId;
    @api isDisable;

    _cubatureLimit;

    @api
    get cubatureLimit() {
        return this._cubatureLimit;
    }

    set cubatureLimit(value) {
        if(value===null){
            this.isAlreadyWarned=true;
            this._cubatureLimit = value;
            return;
        //}else if(value!=null && !this.allCubatureSelected){ // Riprendi Processo salvato in bozza
            //this.checkCubatureLimit();
        }else if(this._cubatureLimit===null){
            this.isAlreadyWarned=false;
        }

        if(this.isCubatureLimited=="Y"){
            if(this._cubatureLimit <= this.allCubatureSelected && value <= this.allCubatureSelected){
                this.showMessage('Attenzione','Il ritiro è a pagamento per i metri cubi selezionati','error');//Cambio di motivazione
                this.closeModal();
            }else if(this._cubatureLimit > this.allCubatureSelected &&  value <= this.allCubatureSelected){
                this.showMessage('Attenzione','Il ritiro è a pagamento per i metri cubi selezionati','error');//vecchio limite ok, nuovo ko
                this.isPaymentNeeded = true;
                this.closeModal();
            }else if(!this._cubatureLimit && this.allCubatureSelected >= value){
                this.showMessage('Attenzione','Il ritiro è a pagamento per i metri cubi selezionati','error');
                this.isPaymentNeeded = true;
                this.closeModal();
            }else if(this._cubatureLimit <= this.allCubatureSelected && value > this.allCubatureSelected){
                this.showMessage('Attenzione','Ritiro non più a pagamento per i metri cubi selezionati','success');//vecchio limite ko, nuovo ok
            }
        }
        this._cubatureLimit = value;
    }

    @track data;
    @track error;
    @track columns = COLUMNS;
    @track searchString;
    @track _initialRecords;
    @track _setGlobalSelectedIds= new Set();
    @track _globalSelectionMap = new Map();
    @track preSelectedKeys= [];
    @track selectedData=[];

    _reloadingTable;
    showModal = false;
    doneTypingInterval = 2000;
    typingTimer;
    showSpinner;
    allCubatureSelected = 0;
    isAlreadyWarned = false;
    isPaymentNeeded;
    volumetricEstimateById;
    
    get isDataSelected(){
        return this.selectedData.length
    }
    
    async getTablesConfig(){
        let wrp = await getTables({ caseId: this.caseId});
        let data =wrp?.volumetricEstimate;
        let preselectedValues = wrp?.preselectedValues;
        let preSelectedKeys = wrp?.preselectedKeys;
        if (data?.length) {
            //console.log("data " + data);
            this.data= data;
            this._initialRecords = data;
            this.preSelectedKeys=preSelectedKeys;
            this.selectedData=preselectedValues;
            preselectedValues?.forEach(elem=>{this._globalSelectionMap.set(elem.Id, elem)});
        }else{
            console.log("#getTablesConfig -> Data not found! ");
        }
    }

    connectedCallback(){
        this.getTablesConfig();
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
            this.checkCubatureLimit();
        }
        
    }

    checkCubatureLimit(){
            this.allCubatureSelected = 0;
            
            this.selectedData.forEach((currentItem)=>{
                    console.log('### currentItem -> ' + currentItem.CubicMeters__c);
                    this.allCubatureSelected += currentItem.CubicMeters__c;
            });   
            this.allCubatureSelected = this.allCubatureSelected.toFixed(2);
            console.log('### allCubatureSelected actual value -> ' + this.allCubatureSelected);

            if(this.isCubatureLimited == 'Y'){
                if(this.allCubatureSelected >= this.cubatureLimit){
                    if(!this.isAlreadyWarned){
                        if(this.showModal){
                            this.showMessage('Attenzione','Il ritiro è a pagamento per i metri cubi selezionati','error');
                        }
                        this.isPaymentNeeded = true;
                        this.isAlreadyWarned = true;
                    }
                }else{
                    if(this.isAlreadyWarned){
                        this.showMessage('Attenzione','Ritiro non più a pagamento per i metri cubi selezionati','success');
                    }
                    this.isPaymentNeeded = false;
                    this.isAlreadyWarned = false;
                }
            }
        // }
    }

    showMessage(title, message, variant) {
        const toastErrorMessage = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastErrorMessage);
    }

    openModal(){
        this.showModal = true;
    }

    closeModal(){
        var labels='';
        var selectedDataIds = [];
        // creazione labels
        this.selectedData.forEach((currentItem)=>{
            console.log('### currentItem Description__c -> ' + currentItem.Description__c);
            labels += currentItem.Description__c + ';';
            selectedDataIds.push(currentItem.Id);
        });  
        labels = labels.slice(0, -1);
        console.log('### allLabels value -> ' + labels);
        console.log('### selectedDataIds -> ' + selectedDataIds); 
        this.createObject(selectedDataIds);

        this.data = this._initialRecords;
        this.preSelectedKeys = [...this._globalSelectionMap.keys()];
        this.showModal = false;

        console.log('### closeModalEvent labels -> ' + labels); 
        console.log('### closeModalEvent isCubatureLimited -> ' + this.isCubatureLimited); 
        console.log('### closeModalEvent isPaymentNeeded  -> ' + this.isPaymentNeeded ); 
        this.dispatchEvent(new CustomEvent('closemodal',{ detail: {
            label: labels, 
            needPayment: this.isCubatureLimited=='Y'? this.isPaymentNeeded : false, 
        }}));
    }

    async createObject(selectedDataIds){
        let createdObject = await createJunctionObj({ caseId : this.caseId, volumetricEsimateIds : selectedDataIds });
        console.log('createdObject are ', createdObject);
        return createdObject;
    }
        
    addRecord(element){
        this.selectedData = [...this.selectedData,element];
    }

    onchangeSearch(event){
        this.showSpinner = true;
        clearTimeout(this.typingTimer);
        let value = event.target.value;
        this.typingTimer = setTimeout(() => {
            if(value){
                this.filterData(value);
            }else{
                console.log('******** Debounce Restore Initial:');
                this.data = this._initialRecords;
                this.preSelectedKeys = [...this._globalSelectionMap.keys()];
            }
            this.showSpinner = false;
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