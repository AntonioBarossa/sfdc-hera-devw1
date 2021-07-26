import { LightningElement, api, track, wire } from 'lwc';
import getData from '@salesforce/apex/HDT_LC_GenericTable.getData';

export default class HdtGenericTable extends LightningElement {

    //inputs 
    @api columns;
    @api rowData;
    @api tableName;
    @api searchTerm;
    @api searchKey;
    @api maxRowSelect;

    //utilities
    @track altMessage;
    @track loader;

    //data are retrieved on the callback, on error alternate will be shown
    connectedCallback(){
        this.loader = true;
        getData({tableName: this.tableName, searchKey: this.searchKey, searchTerm: this.searchTerm})
            .then(data => {
                let objData = JSON.parse(data);
                console.log('Data -> ' + JSON.stringify(objData.columns));
                console.log('Rows -> ' + JSON.stringify(objData.rowData));
                this.columns = objData.columns;
                this.rowData = objData.rowData;
                this.loader = false;
                //console.log('Columns -> ' + JSON.stringify(data.columns));
                //console.log('RowData -> ' + JSON.stringify(data.rowData));
            })
            .catch(error => {
                console.log('Error In Retrievieng data -> ' + JSON.stringify(error));
            })
    }
    getSelectedRecord(event){
        const selectedRow = event.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('rowselect',{detail: selectedRow}));
        console.log(selectedRow);
    }


}