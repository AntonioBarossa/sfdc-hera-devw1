import { LightningElement, track, api } from 'lwc';
import getTabConfiguration from '@salesforce/apex/HDT_LC_AccountStatementController.getTabConfiguration';
import callMulesoft from '@salesforce/apex/HDT_LC_AccountStatementController.callMulesoft';
import operationBackend from '@salesforce/apex/HDT_LC_AccountStatementController.operationBackend';
import sendFileToPrint from '@salesforce/apex/HDT_LC_AccountStatementController.sendFileToPrint';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const idlist = [];
const listToPrint = [];

export default class HdtAccountStatementViewer extends NavigationMixin(LightningElement) {

    uniqueId = '';
    detailTable = '';
    @api recordid;
    @api tabCode;
    @api isLoaded;
    @api statementType;
    @track accountData;
    @track columns;//++++ = columns;
    @track joinFilterModal = false;
    @track error; // to show error message from apex controller.
    @track hasRendered = true;
    @track secondLevelList;
    showSecondLevel;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };
    @track interObj = {};
    techObj = {};
    secondLevelFilter;
    showError = false;
    showErrorMessage = '';
    allData = [];
    allDataFiltered;
    filterOn = false;
    filteredData;
    amountField;
    totAmountStored = 0;
    totAmount = 0;
    checkboxCount = 0;
    
    error;
    showAccountData = true;
    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }

    @track page = 1;//pagination
    @track pages = [];//pagination
    @track pagesList;//pagination
    perpage = 50;//pagination
    set_size = 5;//pagination
    showPagination = true;
    filterPagination = false;
    showOperationModal;

    totRecs;
    fromRec;
    toRec;
    avoidSort;
    blob;
    url;
    fileName;
    showFile = false;
    showAcctStmt = false;;
    @track acctStmt = 'label';

    @track confObj = [];


    connectedCallback() {
        console.log('# connectedCallback #');
        console.log('# recordid -> ' + this.recordid);
        console.log('# statementType -> ' + this.statementType);
        this.techObj.statementType = this.statementType;
        this.techObj.recordId = this.recordid;
        this.techObj.tabCode = this.tabCode;
        this.acctStmt = this.statementType;
        this.openMainSpinner();
        this.getTabConfigurationData();
        this.isLoaded = true;
    }

    renderedCallback() {

        if (this.hasRendered) {
            this.hasRendered = false;
        } else {
            //console.log('# rendered #');
            this.template.querySelectorAll('[data-name="pagination"]').forEach((but) => {
                if(this.page == but.dataset.id){
                    but.variant = 'brand';
                } else {
                    but.variant = 'neutral';
                }
            });

            if(idlist.length > 0){
                this.selectCheckbox();
            }

        }
    }

    handleError(error){
        console.error('e.name => ' + error.name );
        console.error('e.message => ' + error.message);
        console.error('e.stack => ' + error.stack);
        this.dispatchEvent(
            new ShowToastEvent({
                title: error.name,
                message: error.message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    getTabConfigurationData(){
        getTabConfiguration({tabValue: this.tabCode, recordId: this.recordid})
        .then(result => {
            console.log('# Get Columns from Apex #');

            if(result.success){
                this.columns = result.columnObj;
                this.confObj = result.confObj.buttonList;
                console.log('----------> ' + result.confObj.recordCode);
                this.backendCall('home', '');// Chiamata in backend
                this.columns.forEach((i) => {
                    this.interObj[i.fieldName] = '';   
                });

                if(result.confObj.hasAmountField){
                    this.amountField = this.columns.filter(c => { return c.detail.isAmount == true })[0].fieldName;
                    console.log('### I have found for amount -> ' + this.amountField);
                }

                this.uniqueId = 'id';
                this.detailTable = result.confObj.secondLevelAPIname;//'secondoLivello';
                console.log('### Has second level? -> ' + result.confObj.hasSecondLevel);
                this.showSecondLevel = result.confObj.hasSecondLevel;
            } else {
                this.showError = true;
                this.showErrorMessage = result.message;
                this.closeMainSpinner();
            }

        })
        .catch(error => {
            this.handleError(error);
            this.showError = true;
            this.showErrorMessage = 'While getting Tab Configuration';
            this.closeMainSpinner();
        });
    }

    openMainSpinner(){
        const openSpinner = new CustomEvent("openspinner", {
            detail:  ''
        });
        // Dispatches the event.
        this.dispatchEvent(openSpinner);        
    }

    closeMainSpinner(){
        const removeSpinner = new CustomEvent("removespinner", {
            detail:  ''
        });
        // Dispatches the event.
        this.dispatchEvent(removeSpinner);
    }

    @api cancelData(){
        console.log('# cancelData #');
        //cancel all array data
        this.refreshRecord();
        this.allData = [];
        this.accountData = [];
        this.filteredData = [];
        console.log('# length -> ' + this.allData.length);
    }

    @api reopenTab(){
        console.log('# reopenTab #');

        if(this.allData.length == 0){
            console.log('# reload allData');
            if(this.showError){
                this.showError = false;
            }
            
            this.openMainSpinner();
            this.backendCall('home', '');// Chiamata in backend
            this.focusOnButton('home');
        }

    }

    //button handler section --- START ---
    buttonHandler(event){
        try {
            this[event.target.name](event);
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    interrogation(event){
        this.showAccountData = false;
        this.totAmount = 0;
    }

    joinFilter(event) {
        console.log('# joinFilter #');
        this.joinFilterModal = true;
    }

    refreshRecord(){
        //refresh all data in the same service
        this.filterOn = false;
        this.filterPagination = false;
        this.showPagination = true;
        this.totRecs = this.allData.length;
        this.setPages(this.allData.length);
        this.onFirst();
        this.totAmount = this.totAmountStored;
        this.showAccountData = true;
        this.avoidSort = '';
        this.showFile = false;

        for (var key in this.interObj) {
            this.interObj[key] = '';
        }

        this.resetFile();
        this.resetIdList();
        this.refreshSortButton();
    }

    operationClick(){
        console.log('# operationClick #');

        if(idlist.length > 0){
            this.showOperationModal = true;
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

    home(event) {
        var requestType = event.target.name;//event.target.name
        this.handleButtonClick(requestType);
        this.focusOnButton(requestType);
    }

    allRecentItems(event) {
        var requestType = event.target.name;//event.target.name;
        this.handleButtonClick(requestType);
        this.focusOnButton(requestType);
    }

    viewResult(event){
        console.log('# viewResult #');

        if(idlist.length > 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Puoi selezionare solo un record',
                    variant: 'warning'
                })
            );
            return;
        } else if(idlist.length == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non hai selezionato nessun record',
                    variant: 'warning'
                })
            );
            return;
        }

        var nf = this.allData.filter(c => { return c[this.uniqueId] == idlist[0] })[0].numeroFattura;

        if(!nf){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Il record non possiede il numero fattura',
                    variant: 'warning'
                })
            );
            return;            
        }

        this.handleButtonClick(event.target.name, JSON.stringify({numeroFattura: nf}));
        this.focusOnButton(event.target.name);
    }

    printOperation(){
        this.modalObj.isVisible = true;
        this.modalObj.header = 'Conferma la stampa';
        this.modalObj.body = 'Vuoi confermare la stampa del file?',
        this.modalObj.operation = 'print';
    }
    //button handler section --- END ---

    //Checkbox handler section --- START ---
    selectCheckbox(){
        console.log('# selectCheckbox #');
        var count = 0;
        //lightning-input or input
        this.template.querySelectorAll('lightning-input').forEach(li => {
            idlist.forEach((i) => {
                if ( li.type == 'checkbox' && li.name == i) {
                    li.checked = true;
                    count++;
                }            
            });
        });

        if(this.accountData.length == count){
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            ).filter(element => element.name == 'headerCheckbox');
            checked[0].checked = true;
        } else {
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            ).filter(element => element.name == 'headerCheckbox');
            checked[0].checked = false;            
        }
    }

    checkboxHeaderHandler(event){
        console.log('## checkboxHeaderHandler #');
        // Query the DOM
        const checked = Array.from(
            this.template.querySelectorAll('lightning-input')
        )
        // Filter down to checked items
        .filter(element => element.name == 'headerCheckbox')
        // Map checked items to their labels
        .map(element => element.checked);

        this.accountData.forEach((i) => {
            this.template.querySelectorAll('lightning-input').forEach(li => {
                
                if ( li.type == 'checkbox' && li.name == i[this.uniqueId]) {
                    if(checked[0]){
                        li.checked = true;

                        if(!idlist.includes(i[this.uniqueId])){
                            idlist.push(i[this.uniqueId]);
                        }

                    } else {
                        li.checked = false;
                        idlist.splice(idlist.indexOf(i[this.uniqueId]), 1);
                    }
                }
                
            });
        });
        this.checkboxCount = idlist.length.toString();
    }

    checkboxHandler(event){
        
        var i = event.target.value;
        
        if(i == '0'){
            var e = event.currentTarget.dataset.id;

            if (idlist === undefined || idlist.length == 0) {
                //only for the first id of the list
                idlist.push(e);
            } else {
                //if id is already included in the list
                if(idlist.includes(e)){
                    const index = idlist.indexOf(e);
                    if (index > -1) {
                        idlist.splice(index, 1);
                    }
                } else {
                    idlist.push(e);
                }
            }
            event.target.value = '1';

        } else {
            event.target.value = '0';
        }

        this.checkboxCount = idlist.length.toString();
        event.cancelBubble = true;
        event.stopPropagation();
    }
    //Checkbox handler section --- END ---

    closeModal() {
        console.log('# closeModal #');
        this.joinFilterModal = false;
        //this.selid = '';
        this.selectRecordName = '';
    }

    handleRowAction(event) {
        var e = event.currentTarget.dataset.id;
        console.log('# Select row -> ' + e);

        this.accountData.forEach(li => {
            this.template.querySelector('[data-id="' + li[this.uniqueId] + '"]').style.background = '#ffffff';
        });

        //get id row and mark as selected        
        let element = this.template.querySelector('[data-id="' + e + '"]');
        element.style.background = ' #ecebea';

        //get second level list and put in html
        let foundRow = this.accountData.find(ele  => ele[this.uniqueId] === e);
        this.secondLevelList = foundRow[this.detailTable];

    }

    resetIdList(){
        //lightning-input or input
        this.template.querySelectorAll('lightning-input').forEach(li => {
            if ( li.type == 'checkbox' ) {
                li.checked = false;
            }
        });
        idlist.splice(0, idlist.length);
        this.checkboxCount = 0;
    }

    backendCall(requestType, requestObj){
        console.log('# Get data from Mulesoft #');

        this.techObj.requestType = requestType;
        //this.techObj.statementType = this.statementType;

        callMulesoft({techObj: JSON.stringify(this.techObj), requestObj: requestObj})
            .then(result => {
                console.log('# Mulesoft result #');
                console.log('# success: ' + result.success);

                if(result.success){
                    this.allData = result.data;

                    if(result.data.length > this.perpage){
                        this.accountData = result.data.slice(0, this.perpage);
                    } else {
                        this.accountData = this.allData;
                    }

                    this.totAmountStored = result.totAmount;
                    this.totAmount = result.totAmount;
                     this.secondLevelList = result.data[0][this.detailTable];
                    //this.spinnerObj.spinner = false;
                    this.totRecs = this.allData.length;
                    this.fromRec = 1;

                    if(result.data.length > this.perpage){
                        this.toRec = this.perpage;
                    } else {
                        this.toRec = result.data.length;
                    }

                    this.setPages(this.allData.length);
                    //this.spinnerObj.spinner = false;
                    this.closeMainSpinner();
                } else {
                    this.showError = true;
                    this.showErrorMessage = result.message;
                    //this.spinnerObj.spinner = false;
                    this.closeMainSpinner();
                }
               
            })
            .catch(error => {
                this.handleError(error);
                this.closeMainSpinner();
            });

    }

    //Pagination --- START ---
    setPages(dataLength){
        this.pages = [];
        let numberOfPages = Math.ceil(dataLength / this.perpage);
        console.log('# tot recs -> ' + dataLength + ', numberOfPages -> ' + numberOfPages);

        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }

        if(this.pages.length == 1){
            this.showPagination = false;
            return;
        }

        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }

    }

    onPageClick(event){
        console.log('@ ' + parseInt(event.target.dataset.id, 10));
        this.page = parseInt(event.target.dataset.id, 10);
        this.pageData();
    }

    get hasPrev() {
        this.template.querySelectorAll('[data-id="leftArrow"]').forEach((but) => {
            if(this.page > 1){
                but.disabled = false; 
            } else {
                but.disabled = true; 
            }
        });        
        //return this.page > 1;
        return true;
    }

    get hasNext() {
        this.template.querySelectorAll('[data-id="rightArrow"]').forEach((but) => {
            if(this.page < this.pages.length){
                but.disabled = false; 
            } else {
                but.disabled = true; 
            }
        });
               
        return true;
        //return this.page < this.pages.length
    }

    onNext(){
        console.log('+++ ' + this.page);
        this.page++;
        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }
        this.pageData();
    }

    onLast(){
        console.log('+++ ' + this.page);
        this.page = this.pages[this.pages.length-1];
        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }
        this.pageData();
    }

    onFirst(){
        this.page = this.pages[0];
        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }
        this.pageData();
    }

    onPrev(){
        this.page--;
        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }
        this.pageData();
    }

    pageData(){
        console.log('# pageData #');
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);
        
        if(this.filterPagination){
            this.accountData = this.allDataFiltered.slice(startIndex, endIndex);
            this.secondLevelList = this.allDataFiltered[0][this.detailTable];
        } else {
            this.accountData = this.allData.slice(startIndex, endIndex);
            this.secondLevelList = this.accountData[0][this.detailTable];
        }

        this.fromRec = (startIndex == 0) ? 1 : startIndex+1;
        this.toRec = this.fromRec + this.accountData.length - 1 ;
        try{
            this.template.querySelector('.scrolltop').scrollTop = 0;
            this.template.querySelector('.tableScroll').scrollLeft = 0;
        } catch (error){
            console.log('# scrollTop or scrollLeft not found');
        }
        this.refreshSortButton();
        this.refreshHeaderCheckbox();
    }

    pagesList(){
        console.log('# pagesList #');
        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }

    }
    //Pagination --- END ---

    setIntParam(event){
        /// with child component
        var fieldId = event.detail.fieldId;
        console.log('# fieldId ' + fieldId + ', value: ' + event.detail.value);
        this.interObj[fieldId] = event.detail.value;
    }

    applyInterrogation(event){
        console.log('# applyInterrogation # ');
        var currentFilter = {};
        
        for (var key in this.interObj) {
            if(this.interObj[key] != undefined && this.interObj[key] !=''){
                currentFilter[key] = this.interObj[key];
            }
        }

        this.allDataFiltered = this.allData.filter(function(item) {
            for (var key in currentFilter) {
                if (item[key] === undefined || item[key] != currentFilter[key])
                return false;
            }
            return true;
        });

        if(this.allDataFiltered.length == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Nessun record trovato',
                    variant: 'warning'
                }),
            );
            return;
        }

        this.secondLevelList = this.allDataFiltered[0][this.detailTable];
        if(this.amountField != null && this.amountField != ''){
            this.allDataFiltered.forEach((element) => { this.totAmount +=  parseFloat(element[this.amountField]) });
        }
        var firstRowId = this.allDataFiltered[0][this.uniqueId];

        if(this.allDataFiltered.length < this.perpage){
            //we can use only accountData list
            this.showPagination = false;
            this.accountData = this.allDataFiltered;
            this.allDataFiltered = [];
        } else {
            //we need to use allDataFiltered
            this.filterPagination = true;
            this.accountData = this.allDataFiltered.slice(0, this.perpage);
            this.fromRec = 1;
            this.toRec = this.perpage;
            this.totRecs = this.allDataFiltered.length;
            this.setPages(this.totRecs);
        }

        this.filterOn = true;
        this.showAccountData = true;
        let element = this.template.querySelector('[data-id="' + firstRowId + '"]');
        element.style.background = ' #ecebea';

    }

    refreshSortButton(){
        this.template.querySelectorAll('lightning-button-icon').forEach((butIco) => {
            if(butIco.name != this.avoidSort){
                butIco.iconName = 'utility:sort';
            }
        });
    }

    refreshHeaderCheckbox(){
        this.template.querySelectorAll('lightning-input').forEach(li => {
            if ( li.type == 'checkbox' && li.name == 'headerCheckbox' ) {
                li.checked = false;
            }
        });
    }

    sort(event){
        console.log('## sort ## ');

        try {
            var sortField = event.target.name;
            var asc;
            this.avoidSort = sortField;
            console.log('## sort by -> ' + sortField);

            var listToConsider;
            if(!this.filterOn){
                listToConsider = 'allData';
            } else {
                listToConsider = 'allDataFiltered';
            }

            this.template.querySelectorAll('lightning-button-icon').forEach((butIco) => {
                if(butIco.name == sortField){
                    switch (butIco.iconName) {
                        case 'utility:sort':
                            butIco.iconName = 'utility:arrowdown';
                            asc = true;
                            break;
                        case 'utility:arrowdown':
                            butIco.iconName = 'utility:arrowup';
                            asc = false;
                            break;
                        case 'utility:arrowup':
                            butIco.iconName = 'utility:arrowdown';
                            asc = true;       
                    }
                }
            });

            var currentObj = this.columns.filter(c => { return c.fieldName == sortField });

            if(currentObj[0].detail.type == 'number'){
                if(asc){
                    this[listToConsider].sort((a, b) => (parseFloat(a[sortField]) > parseFloat(b[sortField])) ? 1 : -1);
                } else {
                    this[listToConsider].sort((a, b) => (parseFloat(a[sortField]) < parseFloat(b[sortField])) ? 1 : -1);
                }     
            } else {
                if(asc){
                    this[listToConsider].sort((a, b) => (a[sortField] > b[sortField]) ? 1 : -1);
                } else {
                    this[listToConsider].sort((a, b) => (a[sortField] < b[sortField]) ? 1 : -1);
                }     
            }

            this.onFirst();

        } catch(e) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error sorting Records',
                    message: err.message,
                    variant: 'warning'
                }),
            );
        }
     
    }

    refreshSecondLevel(){
        console.log('# refreshSecondLevel #');
        var a = [];
        this.secondLevelList.forEach((i) => {
            a.push(i);
        });
        this.secondLevelList = a;
    }

    modalResponse(event){
        if(event.detail.decision === 'conf'){
            this.printFile();
        }
        this.modalObj.isVisible = false;
    }

    printFile(){
        console.log('# printFile #');

        this.spinnerObj.spinner = true;

        var applySecondFilter = false;
        var filterString = this.template.querySelector("c-hdt-account-statement-detail-viewer").filterString;
        var currentFilter = {};

        if(filterString != undefined && filterString != ''){
            console.log('@ yes we have to filter');
            applySecondFilter = true;
            var myObj = JSON.parse(filterString);

            for (var key in myObj) {
                if(myObj[key] != undefined && myObj[key] !=''){
                    currentFilter[key] = myObj[key];
                }
            }

        }        
        
        var listToConsider;
        if(!this.filterOn){
            //Print all data -> allData if filterOn = false
            listToConsider = 'allData';
        } else if(this.filterOn && this.allDataFiltered.length == 0) {
            //Print accountData if allDataFiltered = 0
            listToConsider = 'accountData';
        } else if(this.filterOn && this.allDataFiltered.length > 0){
            //Print allDataFiltered if allDataFiltered > 0
            listToConsider = 'allDataFiltered';
        }

        this[listToConsider].forEach((r) => {
            //filter second level
            if(applySecondFilter){
                r[this.detailTable] = r[this.detailTable].filter(function(item) {
                    for (var key in currentFilter) {
                        if (item[key] === undefined || item[key] != currentFilter[key])
                            return false;
                    }
                    return true;
                });
            }
            listToPrint.push(r);
        });

        this.sendToApex();
        listToPrint.splice(0, listToPrint.length);
        this.spinnerObj.spinner = false;
        //this.closeMainSpinner();
    }

    sendToApex(){
        console.log('# sendToApex #');
        sendFileToPrint({dataList: JSON.stringify(listToPrint)})
        .then(result => {
            console.log('# save success #');
            console.log('# resp -> ' + result.success);
    
            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };
    
            if(result.success){
                toastObj.title = 'Great Success!';
                toastObj.message = 'The selected record have been printed!';
                toastObj.variant = 'success';


                try{

                    var base64 = result.bodyBase64; 
                    var sliceSize = 512;
                    base64 = base64.replace(/^[^,]+,/, '');
                    base64 = base64.replace(/\s/g, '');
                    var byteCharacters = window.atob(base64);
                    var byteArrays = [];
        
                    for ( var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize ) {
                        var slice = byteCharacters.slice(offset, offset + sliceSize);
                        var byteNumbers = new Array(slice.length);
                        for (var i = 0; i < slice.length; i++) {
                            byteNumbers[i] = slice.charCodeAt(i);
                        }
                        var byteArray = new Uint8Array(byteNumbers);
        
                        byteArrays.push(byteArray);
                    }
        
                    this.blob = new Blob(byteArrays, { type: 'application/pdf' });
                    //var data = new FormData();
                    //data.append("file", blob, "file");

                    const blobURL = URL.createObjectURL(this.blob);
                    //console.log('url-' + blobURL);
                    //window.open(blobURL);
                    this.url = blobURL;
                    this.fileName = 'myFileName.pdf';
                    this.showFile = true;

                    this[NavigationMixin.Navigate](
                        {
                            type: 'standard__webPage',
                            attributes: {
                                url: blobURL
                            }
                        }
                    );

                }catch(err){
                    console.log(err.message);
                }


            } else {
                toastObj.title = 'Something goes wrong!';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
            }
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );
    
        })
        .catch(error => {
            this.handleError(error);
        });
        
    }

    openFile(){
        console.log('# openFile #');
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: this.url
                }
            }
        );        
    }

    resetFile(){
        console.log('# resetFile #');
        this.blob = null;
        this.blobURL = URL.revokeObjectURL();
    }

    closeOpModal(event){
        console.log('# operation on father');
        
        if(event.detail.runflow){
            console.log('@ ' + idlist.join());
            this.operationBackendCall(event.detail.op);
            //todo operation logic goes here
            this.resetIdList();
        }

        this.showOperationModal = false;

    }

    operationBackendCall(op){
        console.log('# operationBackendCall #');

        operationBackend({operation: op, idlist: idlist})
            .then(result => {
                console.log('# operation result #');
                console.log('# result: ' + result.success);
                console.log('# result: ' + result.message);

                if(result.success){


                } else {

                }
                
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    applyFilter(event){
        console.log('# applyFilter #');
        //console.log('# # -> ' + JSON.stringify(filterObject));
        console.log('# filterobj -> ' + event.detail.filterobj);

        //this.backendCall('aggregafiltri', event.detail.filterobj);// Chiamata in backend
        this.handleButtonClick('joinFilter', event.detail.filterobj);
        this.focusOnButton('joinFilter');
    }
    
    handleButtonClick(requestType, requestObj) {
        if(requestType != null && requestType != undefined){

            this.openMainSpinner();
            this.onFirst();
            this.allData = [];
            this.accountData = [];
            this.filteredData = [];
            
            this.resetFile();
            this.resetIdList();
            this.refreshSortButton();

            this.backendCall(requestType, requestObj);// Chiamata in backend
        }

    }

    focusOnButton(thisButton){
        this.template.querySelectorAll('.mainbutton').forEach((but) => {
            but.classList.remove('slds-button_brand');
            but.classList.add('slds-button_neutral');
            if(but.name === thisButton){
                but.classList.add('slds-button_brand');
            }            
        });
    }

    closestmtchoise(){
        this.showAcctStmt = false;
    }

    changeType(){
        this.showAcctStmt = true;
    }

    setNewChoise(event){
        this.acctStmt = event.detail.stmtLabel;
        this.techObj.statementType = this.acctStmt;
        const tipoTransazione = new CustomEvent("settype", {
            detail:  event.detail.stmtName
        });
        // Dispatches the event.
        this.dispatchEvent(tipoTransazione);
        this.closestmtchoise();

        var requestType = 'home';//event.target.name
        this.handleButtonClick(requestType);
        this.focusOnButton(requestType);
    }

}