import { LightningElement, api, track } from 'lwc';
import getProductList from '@salesforce/apex/HDT_LC_ProductAssociation.getProductList';
import runProductOptionAssociation from '@salesforce/apex/HDT_LC_ProductAssociation.runProductOptionAssociation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Custom labels
import cProdOptAssociationCreateTitle from '@salesforce/label/c.ProdOptAssociationCreateTitle';
import cProdOptAssociationDeleteTitle from '@salesforce/label/c.ProdOptAssociationDeleteTitle';
import cProdOptAssociationDeleteSection from '@salesforce/label/c.ProdOptAssociationDeleteSection';
import cProdOptAssociationCreateSection from '@salesforce/label/c.ProdOptAssociationCreateSection';
import cProdOptAssociationConfirmSelection from '@salesforce/label/c.ProdOptAssociationConfirmSelection';
import cProdOptAssociationClose from '@salesforce/label/c.ProdOptAssociationClose';
import cProdOptAssociationCloseDeleteBody from '@salesforce/label/c.ProdOptAssociationCloseDeleteBody';
import cProdOptAssociationCloseCreateBody from '@salesforce/label/c.ProdOptAssociationCloseCreateBody';
import cProdOptAssociationConfimSelectBody from '@salesforce/label/c.ProdOptAssociationConfimSelectBody';
import cProdOptAssociationConfirmFilterTitle from '@salesforce/label/c.ProdOptAssociationConfirmFilterTitle';
import cProdOptAssociationConfirmFilterDeleteBody from '@salesforce/label/c.ProdOptAssociationConfirmFilterDeleteBody';
import cProdOptAssociationConfirmFilterCreateBody from '@salesforce/label/c.ProdOptAssociationConfirmFilterCreateBody';
import cProdOptAssociationConfimSelectBodyDelete from '@salesforce/label/c.ProdOptAssociationConfimSelectBodyDelete';
import cProdOptAssociationResultText from '@salesforce/label/c.ProdOptAssociationResultText';
import cProdOptAssociationNoResultText from '@salesforce/label/c.ProdOptAssociationNoResultText';

const columns = [
    { label: 'Codice prodotto', fieldName: 'ProductCode' },
    { label: 'Versione', fieldName: 'Version__c' },
    { label: 'Nome Prodotto', fieldName: 'Name' },
    { label: 'Servizio', fieldName: 'Service__c' },
    { label: 'Descrizione prodotto', fieldName: 'DescriptionSAP__c' },
    { label: 'Famiglia di prodotti', fieldName: 'Family'},
    { label: 'Categoria Famiglia', fieldName: 'CategoryFamily__c'}
];

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
    checkboxCounter = 0;

    @track selectedIdList = [];

    label = {
        confirmSelectedTitle: cProdOptAssociationConfirmSelection,
        confirmSelectedBody: '',
        closeTitle: cProdOptAssociationClose,
        closeBody: '',
        //confirmAllTitle: '',
        //confirmAllBody: '',
        confirmFilterTitle: cProdOptAssociationConfirmFilterTitle,
        confirmFilterBody: ''
    };
    illustrationMessage;
    
    currentSelectedRows;
    productId = '';
    data = [];
    columns = columns;
    fieldsList = [
        'ProductCode',
        'Version__c',
        'Name',
        'DescriptionSAP__c',
        'CategoryFamily__c',
        'Status__c',
        'TypeOffer__c'
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
    @track page = 1;//pagination
    @track pages = [];//pagination
    @track pagesList;//pagination
    perpage = 200;//pagination
    set_size = 5;//pagination
    totRecs;//pagination
    fromRec;//pagination
    toRec;//pagination

    connectedCallback(){
        console.log('>>> PRODUCT OPTION OBJ: ' + this.productOptionObj);

        this.illustrationMessage = cProdOptAssociationResultText;
        this.page = 1;

        switch (this.dmlContext) {
            case 'delete':
                this.mainTitle = cProdOptAssociationDeleteTitle;
                this.sectionTitle = cProdOptAssociationDeleteSection;
                this.label.confirmSelectedBody = cProdOptAssociationConfimSelectBodyDelete;
                this.label.closeBody = cProdOptAssociationCloseDeleteBody;
                this.label.confirmFilterBody = cProdOptAssociationConfirmFilterDeleteBody;
                break;
            case 'insert':
                this.mainTitle = cProdOptAssociationCreateTitle;
                this.sectionTitle = cProdOptAssociationCreateSection;
                this.label.confirmSelectedBody = cProdOptAssociationConfimSelectBody;
                this.label.closeBody = cProdOptAssociationCloseCreateBody;
                this.label.confirmFilterBody = cProdOptAssociationConfirmFilterCreateBody;
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
        this.getData(jsonRecord, false, '1');

        this.disableButton('confirmFilter', false);
        
    }

    getData(filter, usePagination, pageNumber){
        
        getProductList({filterString: filter, optionalSkuId: this.optionalSkuId, dmlContext: this.dmlContext, usePagination: usePagination, pageNumber: pageNumber})
        .then(result => {
            console.log('>>> GET PRODUCT LIST');

            if(result.success){

                console.log('>>> RESULT SUCCESS');

                if(result.prodList.length===0){
                    console.log('>>> NO DATA');
                    this.data = [];
                    this.showResultTable = false;
                    this.illustrationMessage = cProdOptAssociationNoResultText;
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

        if(selectedRows.length > 0){
            this.disableButton('confirmSelected', false);
        } else {
            this.disableButton('confirmSelected', true);
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

        runProductOptionAssociation({optionalSkuId: this.optionalSkuId, productOptionObj: this.productOptionObj, recordList: this.selectedIdList, executionType: executionType, filterString: this.filterString, dmlContext: this.dmlContext})
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