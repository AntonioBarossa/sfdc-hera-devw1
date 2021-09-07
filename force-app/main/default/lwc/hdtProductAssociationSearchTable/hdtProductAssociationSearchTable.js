import { LightningElement, api, track } from 'lwc';
import getProductList from '@salesforce/apex/HDT_LC_ProductAssociation.getProductList';
import runProductOptionAssociation from '@salesforce/apex/HDT_LC_ProductAssociation.runProductOptionAssociation';

const columns = [
    { label: 'Decrsizione prodotto', fieldName: 'DescriptionSAP__c' },
    { label: 'Versione', fieldName: 'Version__c' },
    { label: 'Codice prodotto', fieldName: 'ProductCode' },
    { label: 'Nome Prodotto', fieldName: 'Name' },
    { label: 'Famiglia', fieldName: 'Family'}
];

export default class HdtProductAssociationSearchTable extends LightningElement {

    @api productOptionId;
    label = {
        confirmSelectedTitle: 'Conferma i prodotti selezionati',
        confirmSelectedBody: 'Attenzione! il prodotto opzione verrà associato a tutti i prodotti selezionati.',
        closeTitle: 'Chiudi la ricerca',
        closeBody: 'Attenzione! Vuoi annullare l\'associazione dell\'opzione prodotto?',
        confirmAllTitle: 'Conferma tutti prodotti a sistema',
        confirmAllBody: 'Attenzione! In questo modo l\'opzione verrà associata a tutti i prodotti a catalogo, vuoi procedere?'
    };
    illustrationMessage = 'I risultati verranno mostrati qui';
    
    productId = '';
    data = [
        //{id: '1', productDescription: 'text', version: 'text', productCode: 'text', productName: 'text', productFamily: 'text'},
        //{id: '2', productDescription: 'text', version: 'text', productCode: 'text', productName: 'text', productFamily: 'text'},
        //{id: '3', productDescription: 'text', version: 'text', productCode: 'text', productName: 'text', productFamily: 'text'},
        //{id: '4', productDescription: 'text', version: 'text', productCode: 'text', productName: 'text', productFamily: 'text'},
        //{id: '5', productDescription: 'text', version: 'text', productCode: 'text', productName: 'text', productFamily: 'text'},
        //{id: '6', productDescription: 'text', version: 'text', productCode: 'text', productName: 'text', productFamily: 'text'}
    ];
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
        
        getProductList({filterString: filter})
        .then(result => {
            console.log('# response #');

            if(result.success){

                if(result.prodList.length===0){
                    this.illustrationMessage = 'Non è stato trovato nessun prodotto';
                } else {
                    console.log('>>> recordCounter: ' + result.recordCounter);
                    this.data = result.prodList;
                    this.showResultTable = true;
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
                case 'goBackToRecord':
                    this.modalObj.header = this.label.closeTitle;
                    this.modalObj.body = this.label.closeBody;
                    break;
                case 'confirmAll':
                    this.modalObj.header = this.label.confirmAllTitle;
                    this.modalObj.body = this.label.confirmAllBody;

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

    confirmSelected(event){
        console.log('>>>> confirmSelected ');

        runProductOptionAssociation({productOptionId: this.productOptionId, recordList: '', selectedAll: false})
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

            setTimeout(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: toastObj.title,
                        message: toastObj.message,
                        variant: toastObj.variant
                    }),
                );
                this.spinnerObj.spinner = false;
                this.goBackToRecord();
            }, 2000);

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

    confirmAll(event){
        console.log('>>>> confirmAll ');
    }

    closeModal(event){
        console.log('### closeModal ###');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

}