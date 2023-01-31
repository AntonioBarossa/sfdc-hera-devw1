import { LightningElement, api } from 'lwc';
import callSap from '@salesforce/apexContinuation/HDT_LC_AccountDataEnrichment.startRequest';
import getTableConfig from '@salesforce/apex/HDT_LC_AccountDataEnrichment.getTableConfig';

export default class HdtAccountDataEnrichment extends LightningElement {
    data = [];
    columns;
    tableTitle;
    iconName;
    height1;

    showSecondTable;
    data2 = [];
    columns2;
    tableTitle2;
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
    @api relatedToId;

    get showSocialBonusButton(){
        return this.type === 'socialBonus';
    }

    connectedCallback(){
        console.log('--------------');
        console.log('### hdtAccountDataEnrichment ###');
        console.log('>>> recordId: ' + this.recordId);
        console.log('>>> type: ' + this.type);
        console.log('>>> relatedToId: ' + this.relatedToId);
        console.log('--------------');
        this.getConfiguration();
        
    }

    getConfiguration(){
        console.log('# getConfiguration #');
    
        getTableConfig({recordId: this.recordId, relatedToId: this.relatedToId, type: this.type})

        .then(result => {

            console.log('# getTableConfig #');
 
            if(this.type == 'cmor'){
                this.showSecondTable = true;
                this.tableTitle = result.tables[0].tableTitle;
                this.iconName = result.tables[0].iconName;
                this.columns = result.tables[0].columns;
                this.height1 = 'topTable';

                this.tableTitle2 = result.tables[1].tableTitle;
                this.iconName2 = result.tables[1].iconName;
                this.columns2 = result.tables[1].columns;
                this.height2 = 'bottomTable';
            } else if(this.type == 'socialBonus') {
                this.tableTitle = result.tables[0].tableTitle;
                this.iconName = result.tables[0].iconName;
                this.columns = result.tables[0].columns;
                this.height1 = 'topTable';
            } else {
                this.tableTitle = result.tables[0].tableTitle;
                this.iconName = result.tables[0].iconName;
                this.columns = result.tables[0].columns;
                this.height1 = 'singleTable';
            } 
            
            this.backendCall();

        }).catch(error => {
            console.log('# error -> ' + error);
            this.showError = true;
            //{"status":500,"body":{"message":"No Customer Code!"},"headers":{}}
            this.showErrorMessage = error.body.message;
            this.showSpinner = false;
        });
    
    }

    backendCall(){
        console.log('# Get data from SAP #');
    
        callSap({recordId: this.recordId, relatedToId: this.relatedToId, type: this.type}).then(result => {
            console.log('# SAP result #');
            var obj = JSON.parse(result);
            console.log('# success: ' + obj.status);

            if(obj.status==='failed'){
                console.log('# SAP result failed #');
                this.showError = true;
                console.log('>>> ' + obj.errorDetails[0].code + ' - ' + obj.errorDetails[0].message);
                this.showErrorMessage = obj.errorDetails[0].code + ' - ' + obj.errorDetails[0].message;
                this.showSpinner = false;            
            } else {
                switch (this.type) {
                    case 'cmor':
                        this.showSecondTable = true;
                        this.data = obj.data.venditoreEntrante;
                        this.data2 = obj.data.venditoreUscente;
                        break;

                    case 'bonusSocialeIdrico':
                        this.data = obj.data;
                        break;
                    case 'gaaView':
                        this.data = obj.data;
                        break;
                    case 'odlAdsView':
                        this.data = obj.data.posizioni;
                        break;
                    default:
                        this.data = obj.data.posizioni;
                }

            }

            this.showSpinner = false;
            
        }).catch(error => {
            console.log('### error: ' + JSON.parse(error));
            this.showError = true;
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

    openKnowledgeArticle(){
        console.log('apertura articolo knowledge con importi bonus sociale');
    }

}