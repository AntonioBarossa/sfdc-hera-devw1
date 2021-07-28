import { LightningElement, track, api } from 'lwc';
import getTabConfiguration from '@salesforce/apex/HDT_LC_AccountStatementController.getTabConfiguration';
//import callMulesoft from '@salesforce/apexContinuation/HDT_LC_AccountStatementController.callMulesoftAsync';
import callMulesoft from '@salesforce/apex/HDT_LC_AccountStatementController.callMulesoft';
import serviceCatalogBackendHandler from '@salesforce/apex/HDT_LC_AccountStatementController.serviceCatalogBackendHandler';
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
    //@track error; // to show error message from apex controller.
    @track hasRendered = true;
    @track secondLevelList;
    showSecondLevel;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };
    @track interObj = {};
    @track firstLevelFilterObj = {};
    techObj = {};
    //secondLevelFilter;
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
    @track showPrintModal = false;
    //error;
    //showAccountData = true;
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
    showFilterFirstLevel = false;
    showOperationModal;
    billParameters;
    otherParams;

    totRecs;
    fromRec;
    toRec;
    avoidSort;
    //blob;
    //url;
    //fileName;
    //showFile = false;
    showAcctStmt = false;;
    @track acctStmt = 'label';
    @track confObj = [];
    showBillList = false;
    showViewResult = false;
    @track viewResultData = {};
    showFilters = false;
    title;
    showFilters2 = false;
    filterType;
    billListHeader;
    @track context;
    @track tipoPlico;

    connectedCallback() {
        console.log('# connectedCallback #');
        console.log('# recordid -> ' + this.recordid);
        console.log('# statementType -> ' + this.statementType);

        //set default value for SAP call
        this.techObj.statementType = this.statementType;
        this.techObj.recordId = this.recordid;
        this.techObj.tabCode = this.tabCode;
        //this.techObj.aggregation = '03';

        this.acctStmt = this.statementType;
        this.openMainSpinner();
        this.getTabConfigurationData();
        this.isLoaded = true;

    }

    renderedCallback() {

        if (this.hasRendered) {
            this.hasRendered = false;
        } else {
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
                console.log('>>> customerCode: ' + result.confObj.customerCode);
                this.techObj.customerCode = result.confObj.customerCode;
                
                if(this.checkBeforeOpenTab()){
                    this.openFilters();
                    this.closeMainSpinner();
                } else {
                    this.backendCall('home', '');// Chiamata in backend
                }

                this.columns.forEach((i) => {
                    this.interObj[i.fieldName] = '';   
                });

                if(result.confObj.hasAmountField){
                    this.amountField = this.columns.filter(c => { return c.detail.isAmount == true })[0].fieldName;
                    console.log('>>> Amount metadata name: ' + this.amountField);
                }

                this.uniqueId = 'id';
                this.detailTable = result.confObj.secondLevelApiName;//'secondoLivello';
                console.log('>>> Has second level? -> ' + result.confObj.hasSecondLevel);
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
            this.showErrorMessage = JSON.stringify(error);
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
        console.log('>>> length -> ' + this.allData.length);
    }

    checkBeforeOpenTab(){
        if(this.tabCode === 'EC5'){
            return true;
        } else {
            return false;
        }        
    }
    @api reopenTab(){
        console.log('# reopenTab #');
        if(this.allData.length == 0){
            if(this.showError){
                this.showError = false;
            }
            
            this.openMainSpinner();
            if(this.checkBeforeOpenTab()){
                this.openFilters();
                this.closeMainSpinner();
            } else {
                this.backendCall('home', '');// Chiamata in backend
            }
            this.focusOnButton('home');
        }
    }
    //button handler section --- START ---
    buttonHandler(event){
        try {
            console.log('>>> BUTTON TYPE > ' + event.currentTarget.dataset.type);
            if(event.currentTarget.dataset.type === undefined){
                console.log('>>> NO BUTTON TYPE SET');
                return;
            }
            switch (event.currentTarget.dataset.type) {
                case 'webservice':
                    this.handleButtonClick(event.target.name);
                    this.focusOnButton(event.target.name);
                    break;
                case 'openmodal':
                    this[event.target.name](event);
                    break;
                case 'lwcmethod':
                    this[event.target.name](event);
            }
        } catch(e){
            console.error('>>> buttonHandler');
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }
    //+++ openmodal button type
    changeType(){
        this.showAcctStmt = true;
    }
    interrogation(event){
        this.title = 'Interrogazione dei dati';
        this.filterLabel = 'Interroga';
        this.showFilterFirstLevel = true;
    }
    joinFilter(event) {
        console.log('# joinFilter #');
        this.joinFilterModal = true;
    }
    contractService(event){
        this.filterType = 'contractService';
        this.showFilters2 = true;
    }
    filterEc7(){
        this.filterType = 'filterEc7';
        this.showFilters2 = true;
    }
    openFilters(){
        this.showFilters = true;
    }
    paperlessFilters(event){
        this.filterType = 'paperlessFilters';
        this.showFilters2 = true;
    }

    viewReminders(event){

        var selectedId = this.getSingleSelectedId();

        if(selectedId==undefined){
            return;
        }
        
        var row = this.allData.filter(c => { return c[this.uniqueId] == selectedId })[0];
        console.log('>>> contoContrattuale: ' + row.contoContrattuale);
        console.log('>>> dataEmissione: ' + row.dataEmissione);

        if(row.dataEmissione === undefined || row.dataEmissione === ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Servizio non disponibile per questo record',
                    variant: 'warning'
                })
            );
            return;
        }  

        this.billParameters = event.currentTarget.dataset.parameters;
        this.otherParams = '';
        this.showBillList = true;  
    }

    modalHandler(event){
        this.billParameters = event.detail.parameters;
        this.otherParams = event.detail.muleRequestParams;
        this.showBillList = true;
    }

    showRate(event){
        this.billParameters = event.currentTarget.dataset.parameters;

        var selectedId = this.getSingleSelectedId();

        if(selectedId==undefined){
            return;
        }
        
        var selected = this.allData.filter(c => { return c[this.uniqueId] == selectedId })[0];
        console.log('>>> contoContrattuale: ' + row.contoContrattuale);
        console.log('>>> dataEmissione: ' + row.dataEmissione);
        console.log('>>> tipoDocumento: ' + row.tipoDocumento);

        var returnError = false;

        if(this.tabCode==='EC4' || this.tabCode==='EC6'){
            if(selected.dataEmissione === undefined || selected.dataEmissione === ''){
                returnError = true;
            }               
    
        } else if(this.tabCode==='EC1' || this.tabCode==='paperless'){
            if((selected.dataEmissione === undefined || selected.dataEmissione === '') &&
                (selected.tipoDocumento === undefined || selected.tipoDocumento === '' || selected.tipoDocumento != 'rate')){
                    returnError = true;
            }
        }

        if(returnError){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Servizio non disponibile per questo record',
                    variant: 'warning'
                })
            );
            return;
        }

        var muleRequestParams = {
            billingProfile: row.contoContrattuale,
            startDate: row.dataEmissione
        };

        this.otherParams = muleRequestParams;
        this.showBillList = true;
    }

    billList(event){
        this.billParameters = event.currentTarget.dataset.parameters;
        //this.otherParams = muleRequestParams;
        this.showBillList = true;
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
        //this.showFile = false;
        for (var key in this.interObj) {
            this.interObj[key] = '';
        }
        this.firstLevelFilterObj = {};
        //this.resetFile();
        this.resetIdList();
        this.refreshSortButton();
        this.setButtonForFilterApplied(false);
    }
    serviceCatalogHandler(){
        this.serviceCatalogBackendHandler('serviceCatalogHandler', null);
    }
    runFlowFromAura(event){
        console.log('>>> PARAMETERS: ' + event.currentTarget.dataset.parameters);
        this.serviceCatalogBackendHandler('runFlowFromAura', event.currentTarget.dataset.parameters);
    }
    serviceCatalogBackendHandler(serviceOperation, parameters){
        console.log('# serviceCatalogBackendHandler #');
        if(idlist.length > 0){
            this.showOperationModal = true;
            var selectedRecord = this.allData.filter(function(item) {
                if(!idlist.includes(item.id))
                    return false;
                
                return true;
            });
            //selectedRecord.forEach(r => {
            //    r[this.detailTable] = [];
            //});
            var recordsString = JSON.stringify(selectedRecord);
            this.serviceCatalogBackendOperation(recordsString, serviceOperation, parameters);
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

    serviceCatalogBackendOperation(recordsString, serviceOperation, parameters){
        console.log('# serviceCatalogBackendOperation #');

        this.openMainSpinner();

        serviceCatalogBackendHandler({tabValue: this.tabCode, recordId: this.recordid, records: recordsString, level: '1'})
        .then(result => {
            console.log('# service Catalog BackenHandler #');

            if(result.success){
                console.log('>>> result > ' + result.serviceCatalogId);
                if(serviceOperation==='serviceCatalogHandler'){
                    this.serviceCatalogEvent(result.serviceCatalogId);
                } else if(serviceOperation==='runFlowFromAura'){
                    this.runFlowFromAuraEvent(result.serviceCatalogId, parameters);
                }
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
            this.handleError(error);
            this.showError = true;
            this.showErrorMessage = JSON.stringify(error);
            this.closeMainSpinner();
        });

    }

    runFlowFromAuraEvent(serviceCatalogId, parameters){
        console.log('>>> runFlowFromAura');
        const serviceCatalog = new CustomEvent("openauracmp", {
            //serviceCatalogId
            detail: {parameters: parameters, accId: this.recordid, catalogId: serviceCatalogId, auraFlow: 'runFlowFromAura'}
        });
        // Dispatches the event.
        this.dispatchEvent(serviceCatalog);
    }

    serviceCatalogEvent(serviceCatalogId){
        const serviceCatalog = new CustomEvent("openauracmp", {
            //serviceCatalogId
            detail: {parameters: this.tabCode, accId: this.recordid, catalogId: serviceCatalogId, auraFlow: 'serviceCatalogHandler'}
        });
        // Dispatches the event.
        this.dispatchEvent(serviceCatalog);
    }

    serviceCatalogEventFromChild(event){
        console.log('>>> serviceCatalog from child > ');
        console.log('>>> serviceCatalog from child > ' + event.detail);
        this.serviceCatalogEvent(event.detail);
    }

    viewResult(event){
        console.log('# viewResult #');

        var selectedId = this.getSingleSelectedId();

        if(selectedId==undefined){
            return;
        }

        var nf = this.allData.filter(c => { return c[this.uniqueId] == selectedId })[0].numeroFattura;

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

        //this.handleButtonClick(event.target.name, JSON.stringify({numeroFattura: nf}));

        this.openMainSpinner();
        this.resetIdList();
        this.backendCall(event.target.name, JSON.stringify({numeroFattura: nf}));
        //this.focusOnButton(event.target.name);

    }

    getSingleSelectedId(){
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
        return idlist[0];
    }

    handleClosePrintModal(event){
        this.showPrintModal = false;
    }
    printEstrattoConto(){
        this.context = 'EC';
        this.tipoPlico = 'Estratto Conto';
        this.printFile();
    }

    printGestioneCredito(){
        this.context = 'GC';
        this.tipoPlico = 'Gestione Credito';
        this.printFile();
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

    handleRowAction(event) {
        var e = event.currentTarget.dataset.id;
        console.log('>>> Select row: ' + e);

        this.accountData.forEach(li => {
            this.template.querySelector('[data-id="' + li[this.uniqueId] + '"]').style.background = '#ffffff';
        });

        //get id row and mark as selected        
        let element = this.template.querySelector('[data-id="' + e + '"]');
        element.style.background = ' #ecebea';

        //get second level list and put in html
        let foundRow = this.accountData.find(ele  => ele[this.uniqueId] === e);
        this.secondLevelList = foundRow[this.detailTable];
        this.firstLevel = foundRow;

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

        console.log('# -- config to call mulesoft -- #');
        console.log(JSON.stringify(this.techObj));
        console.log('--------------------------');

        this.firstLevelFilterObj = {};

        callMulesoft({techObj: JSON.stringify(this.techObj), requestObj: requestObj})
            .then(result => {
                console.log('# Mulesoft result #');
                console.log('>>> success: ' + result.success);

                if(result.success){
                   var obj = JSON.parse(result.data);

                   //console.log('>>>>> ' + JSON.stringify(obj));
                   console.log('>>> REQUEST TYPE -> ' + this.techObj.requestType);

                   if(this.techObj.requestType==='viewResult'){
                       // viewResult logic goes here
                       this.viewResultMulesoftResponse(obj);
                   } else {
                       // other requestType logic goes here
                       this.handleMulesoftResponse(obj);
                   }

                   if(this.showSecondLevel){
                    this.refreshSecondLevelToChild();
                   }

                   this.filterOn = false;

                } else {
                    this.showError = true;
                    this.showErrorMessage = result.message;
                    this.closeMainSpinner();
                }
               
            })
            .catch(error => {
                this.handleError(error);
                this.closeMainSpinner();
            });

    }

    handleMulesoftResponse(obj){
        console.log('>>> data ' + obj.data.length);
        
        if(obj.data.length===0){
            this.closeMainSpinner();
            return;
        }

        this.totAmount = 0;
        if(this.amountField != null && this.amountField != ''){
            obj.data.forEach((e) => { 
                e.id = e['idPrimoLivelloSAP'];
                this.totAmount += parseFloat(e[this.amountField]);
            });
        } else {
            obj.data.forEach((e) => { 
                e.id = e['idPrimoLivelloSAP'];
            });
        }

        this.allData = obj.data;//result.data;

        if(obj.data.length > this.perpage){
            this.accountData = obj.data.slice(0, this.perpage);
        } else {
            this.accountData = this.allData;
        }

        this.totAmountStored = this.totAmount;
        this.firstLevel = obj.data[0];
        this.secondLevelList = obj.data[0][this.detailTable];
        this.totRecs = this.allData.length;
        this.fromRec = 1;

        if(obj.data.length > this.perpage){
            this.toRec = this.perpage;
        } else {
            this.toRec = obj.data.length;
        }

        this.setPages(this.allData.length);
        this.closeMainSpinner();
    }

    viewResultMulesoftResponse(obj){
        console.log('>>> viewResult Mulesoft Response');
        console.log('>>>> viewResult obj > ' + JSON.stringify(obj.data));

        if(obj.data.length > 0){
            this.viewResultData.id = obj.data[0].codiceEsito;
            this.viewResultData.resultDate = obj.data[0].dataEsisto;
            this.viewResultData.resultDetail = obj.data[0].descrizioneEsito;
            this.showViewResult = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Nessun risultato per questa fattura',
                    variant: 'warning'
                }),
            );
        }

        this.closeMainSpinner();
    }

    //Pagination --- START ---
    setPages(dataLength){
        this.pages = [];
        let numberOfPages = Math.ceil(dataLength / this.perpage);
        console.log('>> tot recs: ' + dataLength + ', numberOfPages: ' + numberOfPages);

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
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);

        if(this.filterPagination){
            if(this.allDataFiltered != undefined){
                this.accountData = this.allDataFiltered.slice(startIndex, endIndex);
                this.firstLevel = this.allDataFiltered[0];
                this.secondLevelList = this.allDataFiltered[0][this.detailTable];
            }
        } else {
            if(this.allData != undefined && this.accountData[0] != undefined){
                this.accountData = this.allData.slice(startIndex, endIndex);
                this.firstLevel = this.accountData[0];
                this.secondLevelList = this.accountData[0][this.detailTable];
            }
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
        let mid = Math.floor(this.set_size / 2) + 1;

        if (this.page > mid) {
            this.pagesList = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            this.pagesList = this.pages.slice(0, this.set_size);
        }

    }
    //Pagination --- END ---

    applyInterFromChild(event){
        console.log('# applyInterFromChild #');

        var interObj = JSON.parse(event.detail.value);
        this.firstLevelFilterObj = interObj;
        console.log('interObj ' + event.detail.value);
        this.totAmount = 0;

        try {

            if(interObj && Object.keys(interObj).length === 0 && interObj.constructor === Object){
                console.log('>>> no apply filter');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Non hai inserito nessun parametro',
                        variant: 'info'
                    }),
                );
            } else {
                this.applyInterrogation(interObj);
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
                columnTypeMap.set(col.fieldName, col.detail.type);
            });

            var contoContrArray;
            if(currentFilter.contoContrattuale != undefined && currentFilter.contoContrattuale.value != undefined){
                contoContrArray = currentFilter.contoContrattuale.value.split(',');
            }

            this.allDataFiltered = this.allData.filter(function(item) {
                
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

            this.firstLevel = this.allDataFiltered[0];
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
            this.showFilterFirstLevel = false;
            let element = this.template.querySelector('[data-id="' + firstRowId + '"]');
            element.style.background = ' #ecebea';
        
            this.setButtonForFilterApplied(true);
        } catch (e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack ); 
        }

    }

    setButtonForFilterApplied(disable){
        this.template.querySelectorAll('button').forEach(c => {
            //if(c.name === 'interrogation'){
            //    if(disable){
            //        c.setAttribute('disabled', '');
            //    } else {
            //        c.removeAttribute('disabled');
            //    }
            //}

            if(c.name === 'refreshRecords'){
                if(disable){
                    c.removeAttribute('disabled'); 
                } else {
                    c.setAttribute('disabled', '');
                }
            }

        });
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
            console.log('>>> sort by: ' + sortField);

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

            switch (currentObj[0].detail.type) {
                case 'text':
                    if(asc){
                        this[listToConsider].sort((a, b) => (a[sortField] > b[sortField]) ? 1 : -1);
                    } else {
                        this[listToConsider].sort((a, b) => (a[sortField] < b[sortField]) ? 1 : -1);
                    }
                    break;
                case 'date':

                    this[listToConsider].sort(function(a, b) {

                        var dateSplitted = b[sortField].split('/');
                        var data = dateSplitted[1] + '/' + dateSplitted[0] + '/' + dateSplitted[2];
                        
                        var dateSplitted2 = a[sortField].split('/');
                        var data2 = dateSplitted2[1] + '/' + dateSplitted2[0] + '/' + dateSplitted2[2];

                        if(asc){
                            return (new Date(data) < new Date(data2)) ? 1 : -1;
                        } else {
                            return (new Date(data) > new Date(data2)) ? 1 : -1;
                        }

                    });

                    break;
                case 'number':
                    if(asc){
                        this[listToConsider].sort((a, b) => (parseFloat(a[sortField]) > parseFloat(b[sortField])) ? 1 : -1);
                    } else {
                        this[listToConsider].sort((a, b) => (parseFloat(a[sortField]) < parseFloat(b[sortField])) ? 1 : -1);
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

    refreshSecondLevelToChild(){
        this.template.querySelector("c-hdt-account-statement-detail-viewer").removeFilterFromParent();
    }

    refreshSecondLevel(){
        console.log('# refreshSecondLevel #');
        try {
            if(this.secondLevelList != undefined && this.secondLevelList.length > 0){
                var a = [];
                this.secondLevelList.forEach((i) => {
                    a.push(i);
                });
                this.secondLevelList = a;
            }
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    modalResponse(event){
        if(event.detail.decision === 'conf'){
            this.printFile();
        }
        this.modalObj.isVisible = false;
    }

    printFile(){
        console.log('# printFile #');

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

        if(this.showSecondLevel){
            var currentFilter = this.template.querySelector("c-hdt-account-statement-detail-viewer").staticObj;
            var secondLevelColumns = this.template.querySelector("c-hdt-account-statement-detail-viewer").columns;
            var isSecondLevelFiltered = this.template.querySelector("c-hdt-account-statement-detail-viewer").getIfSecondLevelIsFiltered();

            const columnTypeMap = new Map();
            secondLevelColumns.forEach((col) => {
                columnTypeMap.set(col.fieldName, col.fieldType);
            });

            var contoContrArray;
            if(currentFilter.contoContrattuale != undefined && currentFilter.contoContrattuale.value != undefined){
                contoContrArray = currentFilter.contoContrattuale.value.split(',');
            }
        }

        this[listToConsider].forEach((r) => {
            //filter second level
            if(this.showSecondLevel && isSecondLevelFiltered){
                r[this.detailTable] = this.template.querySelector("c-hdt-account-statement-detail-viewer").getSecondLevelList(r[this.detailTable], currentFilter, columnTypeMap, contoContrArray);
            }
            listToPrint.push(r);
        });

        console.log('sorting documents...');
        
        listToPrint.sort(function (a, b) {
            var dateParts = a.dataScadenza.split("/");
            // month is 0-based, that's why we need dataParts[1] - 1
            var dateObject = new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
            var datePartsb = b.dataScadenza.split("/");
            // month is 0-based, that's why we need dataParts[1] - 1
            var dateObjectb = new Date(+datePartsb[2], datePartsb[1] - 1, +datePartsb[0]);
            return a.contoContrattuale.localeCompare(b.contoContrattuale) || dateObjectb - dateObject;
        });

        this.documents = JSON.stringify(listToPrint);
        console.log('documents ' + this.documents);

        this.showPrintModal = true;
        //this.sendToApex();
        listToPrint.splice(0, listToPrint.length);
        //this.spinnerObj.spinner = false;
        //this.closeMainSpinner();

    }

    //openFile(){
    //    console.log('# openFile #');
    //    this[NavigationMixin.Navigate](
    //        {
    //            type: 'standard__webPage',
    //            attributes: {
    //                url: this.url
    //            }
    //        }
    //    );        
    //}

    //resetFile(){
    //    console.log('# resetFile #');
    //    this.blob = null;
    //    this.blobURL = URL.revokeObjectURL();
    //}

    applyFilter(event){
        console.log('# applyFilter on parent #');
        console.log('>>> filterobj: ' + event.detail.filterobj);
        console.log('>>> requestType: ' + event.detail.requestType);
        
        this.handleButtonClick(event.detail.requestType, event.detail.filterobj);
        this.focusOnButton(event.detail.requestType);

    }
    
    handleButtonClick(requestType, requestObj) {
        if(requestType != null && requestType != undefined){

            this.openMainSpinner();
            
            try{
                this.onFirst();
            } catch (e){
                console.log('>>> check method -> onFirst or pageData');
            }            
            
            this.allData = [];
            this.accountData = [];
            this.filteredData = [];
            this.secondLevelList = [];
            
            //this.resetFile();
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
        this.setButtonForFilterApplied(false);
    }

    setNewChoise(event){
        this.acctStmt = event.detail.stmtLabel;
        this.techObj.statementType = this.acctStmt;
        const tipoTransazione = new CustomEvent("settype", {
            detail:  event.detail.stmtName
        });
        // Dispatches the event.
        this.dispatchEvent(tipoTransazione);
        //this.closestmtchoise();
        this.showAcctStmt = false;

        var requestType = 'home';//event.target.name
        this.handleButtonClick(requestType);
        this.focusOnButton(requestType);
    }

    showSingleBill(event){
        console.log('>>> visualbolletta - showSingleBill');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Visualizza bolletta',
                message: 'Questo servizio non è ancora disponibile',
                variant: 'info',
                mode: 'sticky'
            })
        );
    }
   
    closeModalHandler(event){
        try{
            this[event.detail.booleanVar] = false;
        } catch(e){
            console.log('>>>>>> flop ');
        }        
    }

    removeAllData(){
        this.allData = [];
        this.accountData = [];
        console.log('# refreshSecondLevel #');
        try {
            if(this.secondLevelList != undefined && this.secondLevelList.length > 0){
                var a = [];
                this.secondLevelList = a;
            }

            this.totRecs = 0;
            this.setPages(0);

        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

}