import { LightningElement, api, track } from 'lwc';
import getProductList from '@salesforce/apex/HDT_LC_ProductAssociation.getProductList';
import runProductOptionAssociation from '@salesforce/apex/HDT_LC_ProductAssociation.runProductOptionAssociation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Decrsizione prodotto', fieldName: 'DescriptionSAP__c' },
    { label: 'Versione', fieldName: 'Version__c' },
    { label: 'Codice prodotto', fieldName: 'ProductCode' },
    { label: 'Nome Prodotto', fieldName: 'Name' },
    { label: 'Famiglia', fieldName: 'Family'}
];

const recordIdList = [];

export default class HdtProductAssociationSearchTable extends LightningElement {

    @api productOptionId;
    @api optionalSkuId;
    counter;

    label = {
        confirmSelectedTitle: 'Conferma i prodotti selezionati',
        confirmSelectedBody: 'Attenzione! il prodotto opzione verrà associato a tutti i prodotti selezionati.',
        closeTitle: 'Chiudi la ricerca',
        closeBody: 'Attenzione! Vuoi annullare l\'associazione dell\'opzione prodotto?',
        confirmAllTitle: 'Conferma tutti prodotti a sistema',
        confirmAllBody: 'Attenzione! In questo modo l\'opzione verrà associata a tutti i prodotti a catalogo, vuoi procedere?',
        confirmFilterTitle: 'Conferma tutti prodotti ottenuti dal filtro',
        confirmFilterBody: 'Attenzione! In questo modo l\'opzione verrà associata a tutti i prodotti ottenuti applicando il filtro, vuoi procedere?'
    };
    illustrationMessage = 'I risultati verranno mostrati qui';
    
    productId = '';
    data = [];
    columns = columns;
    fieldsList = [
        'Name',       'TypeOffer__c',   'ProductCode',       'Family',
        'Version__c', 'Status__c',      'DescriptionSAP__c', 'CategoryFamily__c'
    ];
    showResultTable = false;
    
    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }
    spinner = false;

    connectedCallback(){
        console.log('>>> ON SEARCH TABLE: ' + this.productOptionId);
    }

    applyFilter(event){
        console.log('>>>> handleSubmitButtonClick > ');
        this.spinner = true;
        var criteriaObj = {};
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
          criteriaObj[field.fieldName] = field.value;
        });

        var jsonRecord = JSON.stringify(criteriaObj);
        console.log(jsonRecord);
        this.getData(jsonRecord);
        
        //const saverecord = new CustomEvent("saverecord", {
        //  detail: {record: jsonRecord}
        //});
    //
        //// Dispatches the event.
        //this.dispatchEvent(saverecord);

    }

    getData(filter){
        
        getProductList({filterString: filter, optionalSkuId: this.optionalSkuId})
        .then(result => {
            console.log('# response #');

            if(result.success){

                if(result.prodList.length===0){
                    this.illustrationMessage = 'Non è stato trovato nessun prodotto';
                } else {
                    console.log('>>> recordCounter: ' + result.recordCounter);
                    this.data = result.prodList;
                    this.showResultTable = true;
                    this.counter = 'Risultati trovati: ' + result.recordCounter;
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

    //getSelectedRow(event) {
    //    const selectedRows = event.detail.selectedRows;

    //    for (let i = 0; i < selectedRows.length; i++){
    //        console.log("You selected: " + JSON.stringify(selectedRows[i]));
    //    }

    //    console.log('>>> selectedRows ' + selectedRows.length);

    //}

    confirmSelected(event){
        console.log('>>>> confirmSelected ');
        this.spinner = true;
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();

        console.log('>>> selectedRows ' + selected.length);

        for (let i = 0; i < selected.length; i++){
            console.log("You selected: " + JSON.stringify(selected[i]));
            recordIdList.push(selected[i].Id);
        }

        console.log('>>>> recordIdList ' + JSON.stringify(recordIdList));
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
        console.log('>>>> runProductOptionAssociation ');

        runProductOptionAssociation({productOptionId: this.productOptionId, recordList: recordIdList, executionType: executionType})
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

            recordIdList.splice(0, recordIdList.length);
            this.closeModal();
            this.spinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );

            //setTimeout(() => {
            //    this.dispatchEvent(
            //        new ShowToastEvent({
            //            title: toastObj.title,
            //            message: toastObj.message,
            //            variant: toastObj.variant
            //        }),
            //    );
            //    this.spinnerObj.spinner = false;
            //    this.goBackToRecord();
            //}, 2000);

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
        this.delete();
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    delete(event) {
        deleteRecord(this.productOptionId)
            .then(() => {
                console.log('>>>> RECORD DELETED');
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

}