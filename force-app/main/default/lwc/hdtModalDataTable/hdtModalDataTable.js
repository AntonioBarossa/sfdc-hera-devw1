import { LightningElement, track, api, wire } from 'lwc';
import getTableData from  '@salesforce/apex/HDT_LC_OfferConfiguratorController.getTableData';

const firstRow = [
    {
        label: '',
        type: 'button-icon',
        initialWidth: 75,
        typeAttributes: {
                            iconName: 'action:new',
                            title: 'Seleziona',
                            variant: 'border-filled',
                            alternativeText: 'Seleziona'
                        }
    }
];

const amountColumns = [
    {label: 'Valore possibile', fieldName: 'PossibleValue__c'},
    {label: 'Settore', fieldName: 'Sector__c'},
    {label: 'Descrizione', fieldName: 'Description__c'},
];

const grInfoColumns = [
    {label: 'Gr. info', fieldName: 'col1'},
    {label: 'Operando', fieldName: 'col2'},
    {label: 'Stagione', fieldName: 'col3'},
    {label: 'Fine val.', fieldName: 'col4'},
    {label: 'In. val.', fieldName: 'col5'},
    {label: 'Val. acq.', fieldName: 'col6'},
    {label: 'Val.da cl.', fieldName: 'col7'},
    {label: '1ｰ campo chiave di un valore operando', fieldName: 'col8'},
    {label: 'Chiave 2', fieldName: 'col9'},
    {label: 'Chiave 3', fieldName: 'col10'},
    {label: 'Chiave 4', fieldName: 'col11'},
    {label: 'S', fieldName: 'col12'},
    {label: 'Importo', fieldName: 'col13'},
    {label: 'Div.', fieldName: 'col14'}
];

const discountAColumns = [
    {label: 'Valore possibile', fieldName: 'PossibleValue__c'},
    {label: 'Data Inizio Validità', fieldName: 'ValidityStartDate__c'},
    {label: 'Descrizione', fieldName: 'Description__c'},
    {label: 'Settore', fieldName: 'Sector__c'},
    {label: 'Tipo Sconto', fieldName: 'DiscountType__c'},
    {label: 'Valore sconto', fieldName: 'DiscountValue__c'}
];

const discountPColumns = [
    {label: 'Valore possibile', fieldName: 'PossibleValue__c'},
    {label: 'Data Inizio Validità', fieldName: 'ValidityStartDate__c'},
    {label: 'Descrizione', fieldName: 'Description__c'},
    {label: 'Settore', fieldName: 'Sector__c'},
    {label: 'Tipo Sconto', fieldName: 'DiscountType__c'},
    {label: 'Valore sconto', fieldName: 'DiscountValue__c'}
];

const priceQColumns = [
    {label: 'Valore possibile', fieldName: 'PossibleValue__c'},
    {label: 'Data Inizio Validità', fieldName: 'ValidityStartDate__c'},
    {label: 'Descrizione', fieldName: 'Description__c'},
    {label: 'Settore', fieldName: 'Sector__c'},
    {label: 'Tipo Sconto', fieldName: 'DiscountType__c'},
    {label: 'Valore prezzo', fieldName: 'PriceValue__c'}
];

const priceTColumns = [
    {label: 'Valore possibile', fieldName: 'PossibleValue__c'},
    {label: 'Data Inizio Validità', fieldName: 'ValidityStartDate__c'},
    {label: 'Descrizione', fieldName: 'Description__c'},
    {label: 'Settore', fieldName: 'Sector__c'},
    {label: 'Tipo Sconto', fieldName: 'DiscountType__c'},
    {label: 'Valore prezzo', fieldName: 'PriceValue__c'}
];

const priceLColumns = [
    {label: 'Valore possibile', fieldName: 'PossibleValue__c'},
    {label: 'Data Inizio Validità', fieldName: 'ValidityStartDate__c'},
    {label: 'Descrizione', fieldName: 'Description__c'},
    {label: 'Settore', fieldName: 'Sector__c'},
    {label: 'Tipo Sconto', fieldName: 'DiscountType__c'},
    {label: 'Valore prezzo', fieldName: 'PriceValue__c'}
];

export default class HdtModalDataTable extends LightningElement {
    @api relatedToTable;
    @api rowId;
    @api fieldName;
    @api icon;
    @track data = [];
    @track columns = [];
    @track error = {show: false, message: ''};
    @track spinner = true;
    modalHeader;
    iconHeader;

    connectedCallback() {
        this.spinner = true;
        console.log('>>> ' + this.relatedToTable);
        switch (this.relatedToTable) {

            case 'FareTypeList__c':
                this.modalHeader = 'Seleziona la tariffa';
                this.columns = firstRow.concat(amountColumns);
                break;
            case 'DiscountListP__c':
                this.modalHeader = 'Lista Sconti P';
                this.columns = firstRow.concat(discountPColumns);
                break;
            case 'DiscountListA__c':
                this.modalHeader = 'Lista Sconti A';
                this.columns = firstRow.concat(discountAColumns);
                break;                
            case 'PriceListT__c':
                this.modalHeader = 'Lista Prezzi T';
                this.columns = firstRow.concat(priceTColumns);
                break;
            case 'PriceListL__c':
                this.modalHeader = 'Lista Prezzi L';
                this.columns = firstRow.concat(priceLColumns);
                break;
            case 'PriceListQ__c':
                this.modalHeader = 'Lista Prezzi Q';
                this.columns = firstRow.concat(priceQColumns);
                break;        
            case 'infoGroup':
                this.modalHeader = 'Seleziona la GR INFO';
                this.columns = firstRow.concat(grInfoColumns);
                break;
            case 'priceCode':
                this.modalHeader = 'Seleziona il prezzo';
                this.columns = firstRow.concat(priceColumns);
                break;
            case 'RateTemplate__c':
                this.modalHeader = 'Seleziona il RateTemplate__c';
                this.columns = firstRow.concat(priceColumns);
        }

        this.iconHeader = this.icon;
        this.backendCall();
        
    }

    backendCall(){
        console.log('# getTableData #');

        getTableData({objectApiName: this.relatedToTable})
            .then(result => {
                console.log('# call result #');

                if(result){
                    console.log('# success #');
                    this.data = result;
                    //var obj = JSON.parse(result);
                    //this.data = obj[this.fieldName];
                    //console.log(this.data);
                } else {
                    this.error.show = true;
                    this.error.message = 'Backend error';                    
                }
                this.spinner = false;
               
            }).catch(error => {
                this.error.show = true;
                this.error.message = error.body.message;
                this.spinner = false;
            });

    }

    closeModal(event){
        this.data = [];
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);        
    }

    handleRowAction(event) {
        this.data = [];
        const row = event.detail.row;
        this.record = row;

        var recordId = '';
        var recordLabel = '';
        //var fieldName = '';

        switch (this.relatedToTable) {

            case 'FareTypeList__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                //fieldName = 'rateType';
                break;
            case 'infoGroup':

                break;
            case 'priceCode':

                break;


        }

        const selectedEvent = new CustomEvent("setvalue", {
            detail:  {rowId: this.rowId, fieldName: this.fieldName, recId: recordId, label: recordLabel, icon: this.iconHeader}
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }

}