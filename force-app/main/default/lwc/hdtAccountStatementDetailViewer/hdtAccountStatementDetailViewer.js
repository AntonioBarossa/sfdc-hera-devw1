import { LightningElement, track, api, wire } from 'lwc';
import getSecondLevelColumns from '@salesforce/apex/HDT_LC_AccountStatementController.getSecondLevelColumns';
import serviceCatalogBackendHandler from '@salesforce/apex/HDT_LC_AccountStatementController.serviceCatalogBackendHandler';
import getCompanyCode from '@salesforce/apex/HDT_LC_ComunicationsSearchList.getCompanyCode';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};

export default class HdtAccountStatementDetailViewer extends LightningElement {
    @api firstLevel;
    @api accountdetails;
    @api filterString = '';
    @api tabCode;
    @api accountId;
    @api columns;// = columns;
    @track selectedMenuItem;
    @track filterApplied = false;
    @track buttonList;
    @track firstLevelFilterObj = {};
    showButton = false;
    sortedBy;
    sortDirection;// = 'asc';
    bShowModal = false;
    fieldsToFilter = [];
    @api staticObj = {};
    showTotalAmount = false;
    totalAmountLabel = '';

    get totalAmount(){
        var tot = 0;
        if(this.showTotalAmount){
            if(this.accountdetailsToView != undefined){
                this.accountdetailsToView.forEach(c => {
                    tot += parseFloat(c["importo"]);
                });
                console.log('>>> tot ' + tot);     
            }
        }
        return tot;
    }

    get accountdetailsToView(){
        console.log('# accountdetails #');
        console.log('# filterApplied: ' + this.filterApplied);

        if(this.filterApplied && this.bShowModal === false){
            this.applyInterrogation(this.staticObj);
        }

        //this.updateButtonConfig();

        return this.accountdetails;
    }

    connectedCallback(){
        console.log('# DetailViewer connected #');
        this.getTabConfigurationData();
    }

    @api getIfSecondLevelIsFiltered(){
        return this.filterApplied;
    }

    getTabConfigurationData(){
        getSecondLevelColumns({tabValue: this.tabCode})
        .then(result => {
            console.log('# getSecondLevelColumns #');
            console.log('# getSecondLevelColumns: ' + result.success + ' - ' + result.message);

            if(result.success){

                this.columns = result.columnObj;
                this.buttonList = result.buttonList;
                console.log('# buttonList: ' + result.buttonList.length);
                
                this.columns.forEach((i) => {
                    filterObject[i.fieldName] = '';
                    if(i.isFilter){
                        this.fieldsToFilter.push({fieldName: i.fieldName, label: i.label, type: i.type});
                    }

                    i.cellAttributes = {};
                    i.cellAttributes = { alignment: 'left' };

                    if(i.type === 'date'){
                        i.type = 'text';
                        i.dateAttribute = 'sortAsDate';
                    }

                    
                    if(i.isAmountField){
                        this.showTotalAmount = true;
                        this.totalAmountLabel = i.label;
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

    updateButtonConfig(){
        var dataEmissione = '';
        for(var i in this.firstLevel){
            if(i === 'dataEmissione' && this.firstLevel[i] != undefined){
                dataEmissione = this.firstLevel[i];
            }
        }

        this.template.querySelectorAll('button').forEach(c => {    
            if(c.name === 'showRate'){
                if(dataEmissione===''){
                    c.setAttribute('disabled', '');
                } else {
                    c.removeAttribute('disabled');
                }
            }

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

    onHandleSort(event){
        console.log('## sort ## ');

        try {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            var sortField = event.detail.fieldName;
            console.log('>>> sort by: ' + sortField + ' - sortDirection: ' + sortDirection);

            var currentObj = this.columns.filter(c => { return c.fieldName == sortField });
            const cloneData = [...this.accountdetails];

            var currentFieldType = '';
            currentFieldType = currentObj[0].type;
            
            if(currentObj[0].dateAttribute != undefined && currentObj[0].dateAttribute === 'sortAsDate'){
                currentFieldType = 'date';
            }

            console.log('>>> filter type ' + currentFieldType);

            var isAsc;
            if(sortDirection === '' || sortDirection === 'asc'){
                isAsc = true;
                this.sortDirection = 'asc';
            } else {
                isAsc = false;
                this.sortDirection = 'desc';
            }

            switch (currentFieldType) {
                case 'text':
                    if(isAsc){
                        cloneData.sort((a, b) => (a[sortField] > b[sortField]) ? 1 : -1);
                    } else {
                        cloneData.sort((a, b) => (a[sortField] < b[sortField]) ? 1 : -1);
                    }
                    break;
                case 'date':

                    cloneData.sort(function(a, b) {

                        var dateSplitted = b[sortField].split('/');
                        var data = dateSplitted[1] + '/' + dateSplitted[0] + '/' + dateSplitted[2];
                        
                        var dateSplitted2 = a[sortField].split('/');
                        var data2 = dateSplitted2[1] + '/' + dateSplitted2[0] + '/' + dateSplitted2[2];

                        if(isAsc){
                            return (new Date(data) < new Date(data2)) ? 1 : -1;
                        } else {
                            return (new Date(data) > new Date(data2)) ? 1 : -1;
                        }

                    });

                    break;
                case 'currency':
                    if(isAsc){
                        cloneData.sort((a, b) => (parseFloat(a[sortField]) > parseFloat(b[sortField])) ? 1 : -1);
                    } else {
                        cloneData.sort((a, b) => (parseFloat(a[sortField]) < parseFloat(b[sortField])) ? 1 : -1);
                    }
                    break;
                case 'number':
                    if(isAsc){
                        cloneData.sort((a, b) => (parseFloat(a[sortField]) > parseFloat(b[sortField])) ? 1 : -1);
                    } else {
                        cloneData.sort((a, b) => (parseFloat(a[sortField]) < parseFloat(b[sortField])) ? 1 : -1);
                    }
            }

            this.accountdetails = cloneData;
            //this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;

        } catch(e) {
            console.log(e);
        }
     
    }

    // Used to sort the 'Age' column
    /*sortBy(field, reverse, primer) {
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
    }*/

    interrogation(event) {
        console.log('# interrogation #');
        this.bShowModal = true;
    }

    closeModal() {
        console.log('# closeModal DetailViewer #');
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
            this.firstLevelFilterObj = {};

            for (var key in this.filterObject) {
                this.filterObject[key] = '';
            }
            //this.setButtonForFilterApplied(false);

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
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        console.log(JSON.stringify(selected));
        
        if(selected.length > 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non puoi selezionare più record',
                    variant: 'warning'
                })
            );
            return;
        } else if(selected.length === 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non hai selezionato nessun record',
                    variant: 'warning'
                })
            );
            return;
        }

        var docInvoiceObj = {
            billNumber: '',
            channel: 'CRM',
            date: '',
            documentType: 'Bollette',
            company: ''
        };

        this.sendPrint(docInvoiceObj);

    }

    sendPrint(docInvoice){
        
        getCompanyCode({companyName: this.firstLevel.societa})
        .then(result => {
            console.log('>>> getCompanyCode ' + result);
            
            docInvoice.company = result;
            
            const sendToApex = new CustomEvent("printpdf", {
                detail: {obj: JSON.stringify(docInvoice)}
            });
    
            // Dispatches the event.
            this.dispatchEvent(sendToApex);

        }).catch(error => {
            this.error.show = true;
            this.error.message = 'CATCH ERROR MESSAGE';
        });

    }

    showRate(event){
        var paramObj = event.currentTarget.dataset.parameters;
        console.log('on child - ' + paramObj);

        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        console.log(JSON.stringify(selected));
        
        if(selected.length > 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non puoi selezionare più record',
                    variant: 'warning'
                })
            );
            return;
        } else if(selected.length === 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non hai selezionato nessun record',
                    variant: 'warning'
                })
            );
            return;
        }

        if(this.tabCode === 'EC') {
            if(selected.dataEmissionePianoRata === undefined || selected.dataEmissionePianoRata === ''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Servizio non disponibile per questo record',
                        variant: 'warning'
                    })
                );
                return;
            }
        } else if(this.tabCode === 'EC9' || this.tabCode === 'EC6' || this.tabCode === 'EC5') {
            if((selected.dataEmissione === undefined || selected.dataEmissione === '') &&
                (selected.tipoDocumento === undefined || selected.tipoDocumento === '' || selected.tipoDocumento != 'rate')){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Servizio non disponibile per questo record',
                        variant: 'warning'
                    })
                );
                return;
            }
        }

        var muleRequestParams = {
            billingProfile: this.firstLevel.contoContrattuale,
            startDate: this.firstLevel.dataEmissione
        };
        
        const modal = new CustomEvent("modalhandler", {
            detail:  {parameters: paramObj, muleRequestParams: muleRequestParams}
        });
        // Dispatches the event.
        this.dispatchEvent(modal);

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

            this.filterString = '';

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
        this.firstLevelFilterObj = this.staticObj;

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

            var dataToFilter = [];
            this.accountdetails.forEach(element => {
                dataToFilter.push(element);
            });

            const columnTypeMap = new Map();
            this.columns.forEach((col) => {
                columnTypeMap.set(col.fieldName, col.type);
            });
    
            var contoContrArray;
            if(currentFilter.contoContrattuale != undefined && currentFilter.contoContrattuale.value != undefined){
                contoContrArray = currentFilter.contoContrattuale.value.split(',');
            }

            dataToFilter = this.filterMethod(dataToFilter, currentFilter, columnTypeMap, contoContrArray);

            //this.setButtonForFilterApplied(true);
            this.accountdetails = dataToFilter;
            this.filterApplied = true;
            this.closeModal();

        } catch (e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack ); 
        }

    }

    @api getSecondLevelList(parentData, currentFilter, columnTypeMap, contoContrArray){
        var filteredData = [];
        filteredData = this.filterMethod(parentData, currentFilter, columnTypeMap, contoContrArray);
        return filteredData;
    }

    filterMethod(dataToFilter, currentFilter, columnTypeMap, contoContrArray){

        console.log('>>> FILTER METHOD - CHILD NEW');

        dataToFilter = dataToFilter.filter(function(item) {
                
            for (var key in currentFilter) {

                const currentType = columnTypeMap.get(key);
                var filterValue;
                var tableValueToFilter;

                if(item[key] === undefined || item[key] === ''){
                    return false;
                }

                switch (currentType) {
                    case 'currency':
                        filterValue = parseFloat(currentFilter[key].value.replace(',','.'));
                        tableValueToFilter = parseFloat(item[key]);
                        console.log('>>> ' + currentType + ' - filterValue: ' + filterValue + ', tableValueToFilter ' + tableValueToFilter);
                        break;
                    case 'number':
                        filterValue = parseFloat(currentFilter[key].value);
                        tableValueToFilter = parseFloat(item[key]);
                        console.log('>>> ' + currentType + ' - filterValue: ' + filterValue + ', tableValueToFilter ' + tableValueToFilter);
                        break;
                    case 'date':
                        var date = new Date(currentFilter[key].value + 'T00:00:00+0000');
                        filterValue = date.getTime();

                        var cDate = item[key].split('/');
                        var cDate2 = new Date(cDate[2] + '-' + cDate[1] + '-' + cDate[0] + 'T00:00:00+0000');
                        tableValueToFilter = cDate2.getTime();

                        break;
                    case 'text':
                        filterValue = currentFilter[key].value.toLowerCase();
                        tableValueToFilter = item[key].toLowerCase();
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
        return dataToFilter;
    }

    setButtonForFilterApplied(remove){
        this.template.querySelectorAll('button').forEach(c => {
            if(c.name === 'interrogation'){
                if(remove){
                    c.setAttribute('disabled', '');
                } else {
                    c.removeAttribute('disabled');
                }
            }
        });
    }

}