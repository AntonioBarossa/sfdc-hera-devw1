import { LightningElement, track, api, wire } from 'lwc';
import getSecondLevelColumns from '@salesforce/apex/HDT_LC_AccountStatementController.getSecondLevelColumns';
import serviceCatalogBackendHandler from '@salesforce/apex/HDT_LC_AccountStatementController.serviceCatalogBackendHandler';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};

export default class HdtAccountStatementDetailViewer extends LightningElement {
    @api accountdetails;
    @api filterString = '';
    @api tabCode;
    @track columns;// = columns;
    @track selectedMenuItem;
    @track filterApplied = false;
    @track buttonList;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    bShowModal = false;
    fieldsToFilter = [];

    get accountdetailsToView(){
        console.log('# accountdetails #');
        console.log('# filterApplied: ' + this.filterApplied);

        if(this.filterApplied){
            this.innerFilterMethod();
        }

        return this.accountdetails;
    }

    connectedCallback(){
        console.log('# DetailViewer connected #');
        this.getTabConfigurationData();
    }

    getTabConfigurationData(){
        getSecondLevelColumns({tabValue: this.tabCode})
        .then(result => {
            console.log('# getSecondLevelColumns #');

            if(result.success){

                console.log('# getSecondLevelColumns: ' + result.message);

                this.columns = result.columnObj;//columns;
                this.buttonList = result.buttonList;

                this.columns.forEach((i) => {
                    filterObject[i.fieldName] = '';
                    if(i.isFilter){
                        this.fieldsToFilter.push({fieldName: i.fieldName, label: i.label});
                    }
                });

            } else {
                this.showError = true;
                this.showErrorMessage = result.message;
            }

        })
        .catch(error => {
            for(var key in error){
                console.log('# error -> ' + key + '-' + error[key]);
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting Records',
                    message: 'Get Second Level Columns',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
    }

    buttonHandler(event){
        try {
            this[event.target.name](event);
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.accountdetails];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.accountdetails = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    interrogation(event) {
        console.log('# interrogation #');
        this.bShowModal = true;
    }

    closeModal() {
        console.log('# closeModal #');
        this.bShowModal = false;
    }

    applyFilter(event){
        console.log('# applyFilter #');
        
        var s = event.detail.filterobj;
        var o = JSON.parse(s);

        for (var key in filterObject) {
            filterObject[key] = o[key];
        }

        this.filterString = s;
        this.innerFilterMethod();

        this.bShowModal = false;
        this.filterApplied = true;

    }

    innerFilterMethod(){
        console.log('# innerFilterMethod #');
        var currentFilter = {};
        
        for (var key in filterObject) {
            //console.log('# ' + key + ' -> ' + filterObject[key]);
            if(filterObject[key] != undefined && filterObject[key] !=''){
                currentFilter[key] = filterObject[key];
            }
        }

        this.accountdetails = this.accountdetails.filter(function(item) {
            for (var key in currentFilter) {
                if (item[key] === undefined || item[key] != currentFilter[key])
                return false;
            }
            return true;
        });
    }

    removeFilter(){
        console.log('# removeFilter #');

        this.filterApplied = false;
        this.filterString = '';

        for (var key in this.filterObject) {
            this.filterObject[key] = '';
        }

        const removeFilter = new CustomEvent("removefilter", {
            detail:  {filter: 'off'}
        });
        // Dispatches the event.
        this.dispatchEvent(removeFilter);
    }

    serviceCatalog(){
        console.log('# serviceCatalogHandler #');

        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        if(selected.length > 0){
            //this.showOperationModal = true;

            //var i;
            //for(i=0; i<=selected.length; i++){
            //    if(selected[i]!=undefined){
            //        console.log('>' + JSON.stringify(selected[i]));
            //    }
            //}

            var recordsString = JSON.stringify(selected);
            this.serviceCatalogBackendOperation(recordsString);

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non hai selezionato nessun record',
                    variant: 'warning'
                })
            );
        }
 
    }

    serviceCatalogBackendOperation(recordsString){

        console.log('# serviceCatalogBackendOperation #');

        this.openMainSpinner();

        serviceCatalogBackendHandler({tabValue: this.tabCode, recordId: '', records: recordsString, level: '2'})
        .then(result => {
            console.log('# service Catalog BackenHandler #');

            if(result.success){
                console.log('>>> result > ' + result.serviceCatalogId);

                const serviceCatalog = new CustomEvent("servicecatalog", {
                    detail: result.serviceCatalogId
                });
                // Dispatches the event.
                this.dispatchEvent(serviceCatalog);

            } else {
                console.log('>>> result > ' + result.message);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: result.message,
                        variant: 'warning'
                    })
                );
            }

            this.closeMainSpinner();

        })
        .catch(error => {
            //this.handleError(error);
            //this.showError = true;
            //this.showErrorMessage = JSON.stringify(error);
            this.closeMainSpinner();
        });

    }

    openMainSpinner(){
        const openSpinner = new CustomEvent("openmainspinner", {
            detail:  ''
        });
        // Dispatches the event.
        this.dispatchEvent(openSpinner);        
    }

    closeMainSpinner(){
        const removeSpinner = new CustomEvent("closemainspinner", {
            detail:  ''
        });
        // Dispatches the event.
        this.dispatchEvent(removeSpinner);
    }

}