import { LightningElement, api, track } from 'lwc';
import getProductList from '@salesforce/apex/HDT_LC_ProductAssociation.getProductList';
import runProductOptionAssociation from '@salesforce/apex/HDT_LC_ProductAssociation.runProductOptionAssociation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Nome Prodotto', fieldName: 'Name' },
    { label: 'Codice prodotto', fieldName: 'ProductCode' },
    { label: 'Versione', fieldName: 'Version__c' },
    { label: 'Servizio', fieldName: 'Service__c' },
    { label: 'Descrizione prodotto', fieldName: 'DescriptionSAP__c' },
    //{ label: 'Famiglia di prodotti', fieldName: 'Family'},
    { label: 'Categoria Famiglia', fieldName: 'CategoryFamily__c'},
    { label: 'Stato', fieldName: 'Status__c'}
];

const fieldsList = [
    'ProductCode',
    'Version__c',
    //'Name',
    'DescriptionSAP__c',
    'CategoryFamily__c',
    'Status__c',
    'TypeOffer__c',
    'Service__c'
];

export default class HdtProductAssociationSearchTable extends LightningElement {

    @api labels;
    @api objType;
    @api childRecordId;
    @api junctionObj;
    @api dmlContext;
    columns;
    counterText;
    counter;
    filterString;
    mainTitle;
    sectionTitle;
    checkboxCounter = 0;

    @track selectedIdList = [];

    label = {
        confirmSelectedTitle: '',
        confirmSelectedBody: '',
        closeTitle: '',
        closeBody: '',
        confirmFilterTitle:  '',
        confirmFilterBody: ''
    };
    illustrationMessage;
    
    currentSelectedRows;
    recId = '';
    objectApiName = 'Product2';
    data = [];
    columns = columns;
    fieldsList = fieldsList;
    showResultTable = false;
    
    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }
    spinner = false;
    
    showPagination = false;
    @track page = 1;//pagination
    @track pages = [];//pagination
    @track pagesList;//pagination
    perpage = 200;//pagination
    set_size = 5;//pagination
    totRecs;//pagination
    fromRec;//pagination
    toRec;//pagination
    criteriaObj = {};
    enforceConfirmation = false;
    //value = 'In Sviluppo';

    //get options() {
    //    return [
    //        //{ label: 'Annullata', value: 'Annullata'},
    //        { label: 'Confermata', value: 'Confermata'},
    //        { label: 'In Sviluppo', value: 'In Sviluppo'},
    //        { label: 'Vendibile', value: 'Vendibile'},
    //        { label: 'Scaduta', value: 'Scaduta'}
    //    ];
    //}

    connectedCallback(){
        console.log('>>> PRODUCT OPTION OBJ: ' + this.junctionObj);
        console.log('>>> OBJ TYPE: ' + this.objType);
        //console.log('>>> LABELS: ' + JSON.stringify(this.labels));

        this.illustrationMessage = this.labels.cl_ResultText;
        this.page = 1;

        this.label.confirmSelectedTitle = this.labels.cl_ConfirmSelection;
        this.label.closeTitle = this.labels.cl_Close;
        this.label.confirmFilterTitle = this.labels.cl_ConfirmFilterTitle;


        switch (this.dmlContext) {
            case 'delete':
                this.mainTitle = this.labels.cl_DeleteTitle;
                this.sectionTitle = this.labels.cl_DeleteSection;
                this.label.confirmSelectedBody = this.labels.cl_ConfimSelectBodyDelete;
                this.label.closeBody = this.labels.cl_CloseDeleteBody;
                this.label.confirmFilterBody = this.labels.cl_ConfirmFilterDeleteBody;
                break;
            case 'insert':
                this.mainTitle = this.labels.cl_CreateTitle;
                this.sectionTitle = this.labels.cl_CreateSection;
                this.label.confirmSelectedBody = this.labels.cl_ConfimSelectBody;
                this.label.closeBody = this.labels.cl_CloseCreateBody;
                this.label.confirmFilterBody = this.labels.cl_ConfirmFilterCreateBody;
        }

    }

    renderedCallback() {

        this.template.querySelectorAll('[data-name="pagination"]').forEach((but) => {
            if(this.page == but.dataset.id){
                but.variant = 'brand';
            } else {
                but.variant = 'neutral';
            }
        });

    }

    onChangeHandler(event){
        this.criteriaObj[event.currentTarget.name] = event.detail.value;
    }

    applyFilter(event){
        console.log('>>>> APPLY FILTER');
        
        //var criteriaObj = {};
        var nullValue = 0;
        var objLength = 0;
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
          this.criteriaObj[field.fieldName] = field.value;
        });

        for(var key in this.criteriaObj){
            objLength++;
            if(this.criteriaObj[key] === null || this.criteriaObj[key] === ''){
                nullValue++;
            }
        }

        console.log('>>> null value ' + nullValue);
        console.log('>>> obj lenght ' + objLength);

        if(nullValue === objLength){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Devi inserire almeno un filtro',
                    variant: 'warning',
                }),
            );
            return;           
        }

        if(this.criteriaObj.Status__c != undefined && this.criteriaObj.Status__c === 'Annullata'){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non puoi filtrare per questo stato',
                    variant: 'warning',
                }),
            );
            return;
        }

        this.spinner = true;

        var jsonRecord = JSON.stringify(this.criteriaObj);
        console.log(jsonRecord);
        this.filterString = jsonRecord;
        console.log('>>>> FILTER STRING: ' + this.filterString);
        this.showPagination = false;
        this.getData(jsonRecord, false, '1');

        //this.disableButton('confirmFilter', false);
        
    }

    checkValues(){

    }

    getData(filter, usePagination, pageNumber){
        
        getProductList({objType: this.objType, filterString: filter, childRecordId: this.childRecordId, dmlContext: this.dmlContext, usePagination: usePagination, pageNumber: pageNumber})
        .then(result => {
            console.log('>>> GET PRODUCT LIST');

            if(result.success){

                console.log('>>> RESULT SUCCESS');

                if(result.prodList.length===0){
                    console.log('>>> NO DATA');
                    this.data = [];
                    this.showResultTable = false;
                    this.illustrationMessage = this.labels.cl_NoResultText;
                } else {
                    console.log('>>> RECORD RETRIEVED: ' + result.prodList.length);
                    this.data = result.prodList;
                    this.showResultTable = true;

                    if(!usePagination){
                        console.log('>>> RECORD COUNTER: ' + result.recordCounter);
                        this.counterText = 'Risultati trovati: ';
                        this.counter = result.recordCounter;
                        this.setPages(this.counter);

                        if(this.counter > this.perpage){
                            this.showPagination = true;
                        }
                    }

                }

                this.disableButton('confirmFilter', !this.showResultTable);

            } else {
                this.illustrationMessage = result.message;
            }
            this.spinner = false;

        })
        .catch(error => {
            console.log('# save error #');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while saving Record',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleSuccess(event) {
        console.log('>>>> handleSuccess ');
    }

    handleLoad(event){
        console.log('>>>> handleLoad ');
    }

    handleError(event){
        console.log('>>>> handleErrore ');
        console.log('>>>> ' + event.detail.message);
        console.log(JSON.stringify(event.detail.output.fieldErrors));
    }

    handleSubmit(event){
        console.log('>>>> handleSubmit ');
      }

    openConfirmation(event){
        try {
            switch (event.target.name) {
                case 'confirmSelected':
                    this.modalObj.header = this.label.confirmSelectedTitle;
                    this.modalObj.body = this.label.confirmSelectedBody;
                    break;
                case 'closeModal':
                    this.modalObj.header = this.label.closeTitle;
                    this.modalObj.body = this.label.closeBody;
                    break;
                case 'confirmFilter':
                    this.enforceConfirmation = true;
                    this.modalObj.header = this.label.confirmFilterTitle;
                    this.modalObj.body = this.label.confirmFilterBody;
            }

            this.modalObj.isVisible = true;
            this.modalObj.operation = event.target.name;

        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    modalResponse(event){
        try{
            if(event.detail.decision === 'conf'){
                this[event.detail.operation](event);
            }
            this.modalObj.isVisible = false;
            this.enforceConfirmation = false;
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    getSelectedRow(event) {
        const selectedRows = event.detail.selectedRows;

        if(selectedRows.length > 0){
            this.disableButton('confirmSelected', false);
            this.disableButton('confirmFilter', true);
        } else {
            this.disableButton('confirmSelected', true);
            this.disableButton('confirmFilter', false);
        }

        //this.checkboxCounter = this.selectedIdList.length.toString();

    }

    updateSelectedRows(){
        console.log('>>>> confirmSelected ');
        this.spinner = true;
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        console.log('>>> selectedRows ' + selected.length);

        for (let i = 0; i < selected.length; i++){
            //if(!this.selectedIdList.contains(selected[i].Id)){
                console.log("You selected: " + JSON.stringify(selected[i]));
                this.selectedIdList.push(selected[i].Id);
            //}
        }
        console.log('>>>> selectedIdList ' + JSON.stringify(this.selectedIdList));
    }

    confirmSelected(event){
        this.updateSelectedRows();
        this.runProductOptionAssociation('select');
    }

    //confirmAll(event){
    //    console.log('>>>> confirmAll ');
    //    this.runProductOptionAssociation('all');
    //}

    confirmFilter(event){
        console.log('>>>> confirmFiltered ');
        this.runProductOptionAssociation('filter');
    }

    runProductOptionAssociation(executionType){
        console.log('>>>> RUN PRODUCT OPTION ASSOCIATION');
 
        runProductOptionAssociation({objType: this.objType, childRecordId: this.childRecordId, junctionObj: this.junctionObj, recordList: this.selectedIdList, executionType: executionType, filterString: this.filterString, dmlContext: this.dmlContext})
        .then(result => {
            console.log('# response #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
            }

            this.selectedIdList.splice(0, this.selectedIdList.length);
            this.closeModal();
            this.spinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );

        })
        .catch(error => {
            console.log('# save error #');
            console.log('# resp -> ' + result.message);

            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while saving Record',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    closeModal(event){
        console.log('### closeModal ###');

        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    disableButton(buttonName, disable){
        this.template.querySelectorAll('lightning-button').forEach(c => {
            if(c.name===buttonName){
                c.disabled = disable;
            }
        });
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

        this.fromRec = (startIndex == 0) ? 1 : startIndex+1;
        this.toRec = (this.fromRec + perpage)-1;

        console.log('>>> TOT: ' + this.counter + ' - FROM: ' + this.fromRec + ' - TO: ' + this.toRec + ' # pageNumber: ' + this.page);
        this.spinner = true;
        this.updateSelectedRows();
        this.data = [];
        this.getData(this.filterString, true, this.page.toString());

    }
    //Pagination --- END ---

}