import { LightningElement, track, api, wire } from 'lwc';
import getSecondLevelColumns from '@salesforce/apex/HDT_LC_AccountStatementController.getSecondLevelColumns';
import serviceCatalogBackendHandler from '@salesforce/apex/HDT_LC_AccountStatementController.serviceCatalogBackendHandler';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};

export default class HdtAccountStatementDetailViewer extends LightningElement {
    @api firstLevel;
    @api accountdetails;
    @api filterString = '';
    @api tabCode;
    @api accountId;
    @track columns;// = columns;
    @track selectedMenuItem;
    @track filterApplied = false;
    @track buttonList;
    showButton = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    bShowModal = false;
    fieldsToFilter = [];
    staticObj = {};

    get accountdetailsToView(){
        console.log('# accountdetails #');
        console.log('# filterApplied: ' + this.filterApplied);

        if(this.filterApplied){
            //this.innerFilterMethod();
            this.applyInterrogation(this.staticObj);
        }

        /*if(this.firstLevel === undefined){
            console.log('#### undefined ###');
            return [];
        } else {
            console.log('#### NOT undefined ###');
            if(this.firstLevel.secondoLivelloInformativo === undefined){
                return [];
            } else {
                return this.firstLevel.secondoLivelloInformativo;
            }
        }*/

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
            console.log('# getSecondLevelColumns: ' + result.success + ' - ' + result.message);

            if(result.success){

                this.columns = result.columnObj;//columns;
                console.log('# buttonList: ' + result.buttonList.length);

                this.buttonList = result.buttonList;

                this.columns.forEach((i) => {
                    filterObject[i.fieldName] = '';
                    if(i.isFilter){
                        this.fieldsToFilter.push({fieldName: i.fieldName, label: i.label});
                    }
                });

                this.showButton = true;

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

    /*applyFilter(event){
        console.log('# applyFilter #');
 
        var s = event.detail.filterobj;
        var o = JSON.parse(s);

        for (var key in filterObject) {
            filterObject[key] = o[key];
        }

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

        this.filterString = JSON.stringify(currentFilter);

        this.accountdetails = this.accountdetails.filter(function(item) {
            for (var key in currentFilter) {
                if (item[key] === undefined || item[key] != currentFilter[key])
                return false;
            }
            return true;
        });
    }*/

    @api removeFilterFromParent(){
        this.removeFilter();
    }

    removeFilter(){
        console.log('# removeFilter #');

        try {
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
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
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

            var serviceCatalogObj = [];
            var catObj = {};
            for(var i in this.firstLevel){
                catObj[i] = this.firstLevel[i];
            }

            catObj.secondoLivelloInformativo = selected;

            serviceCatalogObj.push(catObj);

            var recordsString = JSON.stringify(serviceCatalogObj);
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

        serviceCatalogBackendHandler({tabValue: this.tabCode, recordId: this.accountId, records: recordsString, level: '2'})
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

    showSingleBill(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Attenzione',
                message: 'Servizio in sviluppo',
                variant: 'info'
            })
        );
    }

    showRate(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Attenzione',
                message: 'Servizio in sviluppo',
                variant: 'info'
            })
        );
    }

    viewInvoice(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Attenzione',
                message: 'Servizio in sviluppo',
                variant: 'info'
            })
        );
    }

    generateFilterString(){
        try {
            for(var i in this.staticObj){
                this.filterString += i;
                this.filterString += ' ';
                for(var n in this.staticObj[i]){
                    this.filterString += this.staticObj[i][n] + ' ';
                }
                this.filterString += ', ';
            }
        } catch (error) {
            this.filterString = JSON.stringify(this.staticObj);
        }
    }

    //method to filter record on second level
    applyInterFromChild(event){
        console.log('# applyInterFromChild #');

        this.staticObj = JSON.parse(event.detail.value);

        try {

            if(this.staticObj && Object.keys(this.staticObj).length === 0 && this.staticObj.constructor === Object){
                console.log('>>> no apply filter');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Non hai inserito nessun parametro',
                        variant: 'info'
                    }),
                );
            } else {
                this.applyInterrogation(this.staticObj);
                this.generateFilterString();
            }

        } catch (error) {
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );            
        }
        

    }

    applyInterrogation(currentFilter){
        console.log('# applyInterrogation # ');

        try{

            const columnTypeMap = new Map();
            this.columns.forEach((col) => {
                columnTypeMap.set(col.fieldName, 'text'/*col.detail.type*/);
            });

            var contoContrArray;
            if(currentFilter.contoContrattuale != undefined && currentFilter.contoContrattuale.value != undefined){
                contoContrArray = currentFilter.contoContrattuale.value.split(',');
            }

            var filteredData = [];
            filteredData = this.accountdetails.filter(function(item) {
                
                for (var key in currentFilter) {

                    const currentType = columnTypeMap.get(key);
                    var filterValue;
                    var tableValueToFilter;

                    if(item[key] === undefined || item[key] === ''){
                        return false;
                    }

                    switch (currentType) {
                        case 'number':
                            filterValue = parseFloat(currentFilter[key].value);
                            tableValueToFilter = parseFloat(item[key]);
                            break;
                        case 'date':
                            var date = new Date(currentFilter[key].value + 'T00:00:00+0000');
                            filterValue = date.getTime();

                            var cDate = item[key].split('/');
                            var cDate2 = new Date(cDate[2] + '-' + cDate[1] + '-' + cDate[0] + 'T00:00:00+0000');
                            tableValueToFilter = cDate2.getTime();

                            break;
                        case 'text':
                            filterValue = currentFilter[key].value;
                            tableValueToFilter = item[key];
                    }

                    switch (currentFilter[key].operator) {
                        case '='://uguale a
                            if (tableValueToFilter != filterValue)
                            return false;
                            break;
                        case '>'://maggiore di
                            if (tableValueToFilter <= filterValue)
                            return false;
                            break;
                        case 'in'://contiene caratteri
                            if(!tableValueToFilter.includes(filterValue))
                            return false;
                            break;
                        case 'on'://contiene valori
                            if(!contoContrArray.includes(tableValueToFilter))
                            return false;
                    }

                }
                return true;
            });

            if(filteredData.length == 0 && this.bShowModal){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Nessun record trovato',
                        variant: 'warning'
                    }),
                );
                return;
            }
            this.accountdetails = filteredData;
            this.filterApplied = true;
            this.closeModal();

        } catch (e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack ); 
        }

    }

}