import { LightningElement,api,track } from 'lwc';
import getListRecords from '@salesforce/apex/HDT_LC_GenericRecordSelection.getListRecords';

export default class HdtGenericRecordSelection extends LightningElement {

    @api searchLabel;
    @api searchVariant;
    @api searchPlaceholder;
    @api maxRow;
    @api results;
    @api accountId;
    @api queryParams;
    @api columns;

    @track data;
    @track isLoading;
    @track queryParamsString;
    @track showNoRecordMessage = false;

    handleKeyUp(event){
        try{
        if (event.keyCode === 13) {
            var inp=this.template.querySelector("lightning-input");
            var temp = Object.assign({}, JSON.parse(this.queryParams));
            if(inp.value != null && inp.value != ""){
                temp.soslSearchTerm = inp.value;
            }
            this.queryParamsString = JSON.stringify(temp);
            this.getListRecords();
        }
        }catch(error){
            console.error(error);        
        }   
    }

    getListRecords(){
        try{
            getListRecords({
                params: this.queryParamsString
                })
                .then(result => {
                    var wiredResponse = JSON.parse(result);
                    if(Object.keys(wiredResponse[0]).length > 0){
                        this.data = wiredResponse[0];
                        this.showNoRecordMessage = false;
                    }else{
                        this.data = null;
                        this.showNoRecordMessage = true;
                    }
                    
                    this.isLoading = false;
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error) + ' ' + this.queryParamsString);
                    this.isLoading = false;
                });
            }catch(error){
                console.error(error);
            }
    }

    connectedCallback(){
        this.isLoading = true;
        this.queryParamsString = this.queryParams;
        this.columns = JSON.parse(this.columns);
        this.getListRecords();
    }
    handleRowSelection(event){
        const selectedRows = event.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('recordselected', {detail: {selectedRows}}));

     
    }
    
}