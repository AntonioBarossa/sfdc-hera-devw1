import { LightningElement, api } from 'lwc';
//import callWebService from '@salesforce/apexContinuation/HDT_LC_PracticesView.startRequest';
import callWebService from '@salesforce/apex/HDT_LC_PracticesView.callWebService';
import getTableConfig from '@salesforce/apex/HDT_LC_PracticesView.getTableConfig';

export default class HdtPracticesView extends LightningElement {
    data = [];
    columns;
    tableTitle;
    tableName1;
    iconName;
    height1;

    showSecondTable;
    data2 = [];
    columns2;
    tableTitle2;
    tableName2;
    iconName2;
    height2;

    showError = false;
    showErrorMessage = '';
    showSpinner = true;
    
    //defaultSortDirection = 'desc';
    sortDirection = 'desc';
    sortedBy;
    //asc = true;

    @api recordId;
    @api type;

    connectedCallback(){
        console.log('# type: ' + this.type);
        this.getConfiguration();
    }

    getConfiguration(){
        console.log('# getConfiguration #');
    
        getTableConfig({recordId: this.recordId, type: this.type})

        .then(result => {

            console.log('# getTableConfig #');
 
            this.showSecondTable = true;
            this.tableTitle = result.tables[0].tableTitle;
            this.tableName1 = result.tables[0].tableName;
            this.iconName = result.tables[0].iconName;
            this.columns = result.tables[0].columns;
            this.height1 = 'topTable';

            this.tableTitle2 = result.tables[1].tableTitle;
            this.tableName2 = result.tables[1].tableName;
            this.iconName2 = result.tables[1].iconName;
            this.columns2 = result.tables[1].columns;
            this.height2 = 'bottomTable';
            this.backendCall();
        }).catch(error => {
            console.log('# error -> ' + JSON.stringify(error));
            this.showError = true;
            this.showErrorMessage = error.body.message;
            this.showSpinner = false;
        });
    
    }

    backendCall(){
        console.log('# Get data from SAP #');
    
        callWebService({recordId: this.recordId, type: this.type}).then(result => {

            this.showSecondTable = true;
            this.data = result[this.tableName1];
            this.data2 = result[this.tableName2];
            this.showSpinner = false;
            
        }).catch(error => {
            console.log('# error: ' + JSON.stringify(error));
            //var obj = JSON.parse(error.body.message);
            this.showError = true;
            //var s = '';
            //obj.errorDetails.forEach(element => {
            //    s += element.code + ': ' + element.message;
            //});
            this.showErrorMessage = error.body.message;
            this.showSpinner = false;
        });
    
    }

    onHandleSort(event){
        console.log('## sort event ## ');

        try {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            var sortField = sortedBy;

            this.sortingMethod(sortField, sortDirection, 'data');

            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;

        } catch(e) {
            console.log(e);
        }
     
    }

    onHandleSort2(event){
        console.log('## sort event ## ');

        try {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            var sortField = sortedBy;

            this.sortingMethod(sortField, sortDirection, 'data2');

            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;

        } catch(e) {
            console.log(e);
        }
     
    }

    sortingMethod(sortField, sortDirection, dataTable){
        console.log('## sortingMethod ## ');

        try {

            console.log('>>> sort by: ' + sortField);
            console.log('>>> sortDirection: ' + sortDirection);

            const cloneData = [...this[dataTable]];

            cloneData.sort(function(a, b) {
                var dateSplitted = b[sortField].split('/');

                var data;
                if(dateSplitted.length < 3){
                    data = dateSplitted[1] + '/' + dateSplitted[0] + '/01';
                } else {
                    data = dateSplitted[1] + '/' + dateSplitted[0] + '/' + dateSplitted[2];
                }
                
                var dateSplitted2 = a[sortField].split('/');
                var data2;
                if(dateSplitted.length < 3){
                    data2 = dateSplitted2[1] + '/' + dateSplitted2[0] + '/01';
                } else {
                    data2 = dateSplitted2[1] + '/' + dateSplitted2[0] + '/' + dateSplitted2[2];
                }

                if(sortDirection === 'asc'){
                    return (new Date(data) > new Date(data2)) ? 1 : -1;
                } else {
                    return (new Date(data) < new Date(data2)) ? 1 : -1;
                }

            });
            this[dataTable] = cloneData;
        } catch(e) {
            console.log(e);
        }
    }

}