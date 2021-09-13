import { LightningElement, api, track } from 'lwc';
import getProductList from '@salesforce/apex/HDT_LC_ProductAssociation.getProductList';
import runProductOptionAssociation from '@salesforce/apex/HDT_LC_ProductAssociation.runProductOptionAssociation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Codice prodotto', fieldName: 'ProductCode' },
    { label: 'Versione', fieldName: 'Version__c' },
    { label: 'Nome Prodotto', fieldName: 'Name' },
    { label: 'Descrizione prodotto', fieldName: 'DescriptionSAP__c' },
    { label: 'Famiglia di prodotti', fieldName: 'Family'},
    { label: 'Categoria Famiglia', fieldName: 'CategoryFamily__c'}
];

const selectedIdList = [];

export default class HdtProductAssociationSearchTable extends LightningElement {

    @api productOptionId;
    @api optionalSkuId;
    @api productOptionObj;
    @api dmlContext;
    counterText;
    counter;
    filterString;
    mainTitle;
    sectionTitle;

    label = {
        confirmSelectedTitle: '',
        confirmSelectedBody: '',
        closeTitle: '',
        closeBody: '',
        confirmAllTitle: '',
        confirmAllBody: '',
        confirmFilterTitle: '',
        confirmFilterBody: ''
    };
    illustrationMessage;
    
    productId = '';
    data = [];
    columns = columns;
    fieldsList = [
        'Name',
        'DescriptionSAP__c',
        'ProductCode',
        //'Family',
        'Version__c',
        'Status__c',
        'TypeOffer__c',
        'CategoryFamily__c'
    ];
    showResultTable = false;
    
    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }
    spinner = false;
    showPagination = false;
    //pagesList = ['1', '2', '3', '4', '5'];
    currentPageNumber;

    @track page = 1;//pagination
    @track pages = [];//pagination
    @track pagesList;//pagination
    perpage = 50;//pagination
    set_size = 5;//pagination
    totRecs;//pagination
    fromRec;//pagination
    toRec;//pagination

    connectedCallback(){
        console.log('>>> PRODUCT OPTION OBJ: ' + this.productOptionObj);

        this.illustrationMessage = 'I risultati verranno mostrati qui';
        this.currentPageNumber = 1;

        switch (this.dmlContext) {
            case 'delete':
                this.mainTitle = 'Rimozione Massiva del prodotto opzione';
                this.sectionTitle = 'Da questi elementi puoi eliminare il prodotto opzione';
                this.label.confirmSelectedTitle = 'Conferma i prodotti selezionati';
                this.label.confirmSelectedBody = 'Attenzione! il prodotto opzione verrà rimosso da tutti i prodotti selezionati.';
                this.label.closeTitle = 'Chiudi la ricerca';
                this.label.closeBody = 'Attenzione! Vuoi annullare la rimozione dell\'opzione prodotto?';
                this.label.confirmAllTitle = 'Conferma tutti prodotti a sistema';
                this.label.confirmAllBody = 'Attenzione! In questo modo l\'opzione verrà eliminata da tutti i prodotti a catalogo, vuoi procedere?';
                this.label.confirmFilterTitle = 'Conferma tutti prodotti ottenuti dal filtro';
                this.label.confirmFilterBody = 'Attenzione! In questo modo l\'opzione verrà eliminata da tutti i prodotti ottenuti applicando il filtro, vuoi procedere?';
                break;
            case 'insert':
                this.mainTitle = 'Associazione Massiva del prodotto opzione';
                this.sectionTitle = 'Su questi elementi puoi associare il prodotto opzione';
                this.label.confirmSelectedTitle = 'Conferma i prodotti selezionati';
                this.label.confirmSelectedBody = 'Attenzione! il prodotto opzione verrà associato a tutti i prodotti selezionati.';
                this.label.closeTitle = 'Chiudi la ricerca';
                this.label.closeBody = 'Attenzione! Vuoi annullare l\'associazione dell\'opzione prodotto?';
                this.label.confirmAllTitle = 'Conferma tutti prodotti a sistema';
                this.label.confirmAllBody = 'Attenzione! In questo modo l\'opzione verrà associata a tutti i prodotti a catalogo, vuoi procedere?';
                this.label.confirmFilterTitle = 'Conferma tutti prodotti ottenuti dal filtro';
                this.label.confirmFilterBody = 'Attenzione! In questo modo l\'opzione verrà associata a tutti i prodotti ottenuti applicando il filtro, vuoi procedere?';
        }

    }

    applyFilter(event){
        console.log('>>>> APPLY FILTER');
        this.spinner = true;
        var criteriaObj = {};
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
          criteriaObj[field.fieldName] = field.value;
        });

        var jsonRecord = JSON.stringify(criteriaObj);
        console.log(jsonRecord);
        this.filterString = jsonRecord;
        console.log('>>>> FILTER STRING: ' + this.filterString);
        this.showPagination = false;
        this.getData(jsonRecord);

        this.disableButton('confirmFilter', false);
        
    }

    getData(filter){
        
        getProductList({filterString: filter, optionalSkuId: this.optionalSkuId, dmlContext: this.dmlContext})
        .then(result => {
            console.log('>>> GET PRODUCT LIST');

            if(result.success){

                if(result.prodList.length===0){
                    this.illustrationMessage = 'Non è stato trovato nessun prodotto';
                } else {
                    console.log('>>> RECORD COUNTER: ' + result.recordCounter);
                    this.data = result.prodList;
                    this.showResultTable = true;
                    this.counterText = 'Risultati trovati: ';
                    this.counter = result.recordCounter;
                    this.setPages(this.counter);
                    this.showPagination = true;
                }

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
                case 'confirmAll':
                    this.modalObj.header = this.label.confirmAllTitle;
                    this.modalObj.body = this.label.confirmAllBody;
                    break;
                case 'confirmFilter':
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
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    getSelectedRow(event) {
        const selectedRows = event.detail.selectedRows;

        //console.log('>>> selectedIdList ' + JSON.stringify(selectedIdList));

        if(selectedRows.length > 0){
            this.disableButton('confirmSelected', false);
        } else {
            this.disableButton('confirmSelected', true);
        }

    }

    confirmSelected(event){
        console.log('>>>> confirmSelected ');
        this.spinner = true;
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        console.log('>>> selectedRows ' + selected.length);

        for (let i = 0; i < selected.length; i++){
            console.log("You selected: " + JSON.stringify(selected[i]));
            selectedIdList.push(selected[i].Id);
        }

        console.log('>>>> selectedIdList ' + JSON.stringify(selectedIdList));
        this.runProductOptionAssociation('select');
    }

    confirmAll(event){
        console.log('>>>> confirmAll ');
        this.runProductOptionAssociation('all');
    }

    confirmFilter(event){
        console.log('>>>> confirmFiltered ');
        this.runProductOptionAssociation('filter');
    }

    runProductOptionAssociation(executionType){
        console.log('>>>> RUN PRODUCT OPTION ASSOCIATION');

        runProductOptionAssociation({optionalSkuId: this.optionalSkuId, productOptionObj: this.productOptionObj, recordList: selectedIdList, executionType: executionType, filterString: this.filterString, dmlContext: this.dmlContext})
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

            selectedIdList.splice(0, selectedIdList.length);
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

    paginationClick(event){

        console.log('>>> PAGE NUMBER ' + this.currentPageNumber);

        /*var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        for (let i = 0; i < selected.length; i++){
            selectedIdList.push(selected[i].Id);
        }

        this.spinner = true;
        this.getData(this.filterString);
        //this.disableButton('confirmFilter', false);
        this.showPagination = true;*/
    }

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

        /*if(this.filterPagination){
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
        this.refreshHeaderCheckbox();*/
    }
    //Pagination --- END ---

}