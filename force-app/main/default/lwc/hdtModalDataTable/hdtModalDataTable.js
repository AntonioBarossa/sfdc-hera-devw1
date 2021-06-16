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
    {label: 'Valore possibile', fieldName: 'PossibleValue__c', type: 'text'},
    {label: 'Settore', fieldName: 'Sector__c', type: 'text'},
    {label: 'Descrizione', fieldName: 'Description__c', type: 'text'},
];

const grInfoColumns = [
    {label: 'Valore Possibile', fieldName: 'PossibleValue__c'},
    {label: 'Descrizione Valore', fieldName: 'ValueDescription__c'},
    {label: 'Det Tariffa', fieldName: 'DetRate__c'}
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
    @api rate;
    @track data = [];
    @track columns = [];
    @track error = {show: false, message: ''};
    @track spinner = true;
    emptyTable = true;
    modalHeader;
    iconHeader;
    searchByField = '';
    searchValue = '';

    get options() {
        return [
            { label: 'Descrizione', value: 'ValueDescription__c' },
            { label: 'Descrizione', value: 'Description__c' },
            { label: 'Nome', value: 'Name' },
            { label: 'Stato', value: 'Status__c' },
        ];
    }

    connectedCallback() {
        this.spinner = true;
        console.log('>>> ' + this.relatedToTable + ' - rate cat >>> ' + this.rate);
        this.searchByField = 'Description__c';
        
        switch (this.relatedToTable) {

            case 'FareTypeList__c':
                this.modalHeader = 'Seleziona la tariffa';
                this.columns = firstRow.concat(amountColumns);
                break;
            case 'DiscountListP__c':
                this.modalHeader = 'Lista Sconti P';
                this.columns = firstRow.concat(discountPColumns);
                break;
            case 'DiscountListaA__c':
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
                this.searchByField = 'ValueDescription__c';
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

        getTableData({objectApiName: this.relatedToTable, rate: this.rate, searchByField: this.searchByField, searchValue: this.searchValue})
            .then(result => {
                console.log('# call result #');

                if(result){
                    console.log('# success #');
                    this.data = result;

                    this.emptyTable = false; 
                    if(result.length === 0){
                        //this.error.show = true;
                        //this.error.message = 'Non è stato trovato nessun valore';
                        this.emptyTable = true;                      
                    }

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

        switch (this.relatedToTable) {

            case 'FareTypeList__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;
            case 'DiscountListP__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;
            case 'DiscountListaA__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;                
            case 'PriceListT__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;
            case 'PriceListL__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;
            case 'PriceListQ__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;        
            case 'infoGroup':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;
            case 'priceCode':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
                break;
            case 'RateTemplate__c':
                recordId = this.record['PossibleValue__c'];
                recordLabel = this.record['PossibleValue__c'];
        }

        const selectedEvent = new CustomEvent("setvalue", {
            detail:  {rowId: this.rowId, fieldName: this.fieldName, recId: recordId, label: recordLabel, icon: this.iconHeader}
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }

    handleFieldChange(event){

    }

    setFieldValue(event){
        //var fieldName = event.currentTarget.name;
        //var rowId =  event.currentTarget.dataset.rowId;
        this.searchValue = event.target.value;
        //var type = event.currentTarget.type;

    }

    search(){
        console.log('>>> searchByField: ' + this.searchByField + ', field: ' + this.searchValue);
        console.log('>>> relatedToTable > ' + this.relatedToTable + ' - rate: ' + this.rate);
        this.backendCall();
    }

    refresh(){
        this.searchValue = '';
        this.backendCall();
    }

}