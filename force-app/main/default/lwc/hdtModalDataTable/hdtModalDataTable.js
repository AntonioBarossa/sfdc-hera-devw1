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

    //{label: 'Tipo Tariffa', fieldName: 'col1'},
    //{label: 'Settore Merceologico', fieldName: 'col2'},
    //{label: 'Classe Calcolo', fieldName: 'col3'},
    //{label: 'Numeratore Ammesso', fieldName: 'col4', type: 'boolean'},
    //{label: 'Apparecchiatura Ammessa', fieldName: 'col5', type: 'boolean'},
    //{label: 'Info Ammesse', fieldName: 'col6', type: 'boolean'},
    //{label: 'Ammissibilità contatori dell\'intervallo', fieldName: 'col7', type: 'boolean'},
    //{label: 'Ammesso per calcolo finale', fieldName: 'col8', type: 'boolean'},
    //{label: 'Ammissibilità nel calcolo dei rifiuti', fieldName: 'col9', type: 'boolean'},
    //{label: 'Ignorare attr. contr. del numeratore durante estrapolazione', fieldName: 'col10', type: 'boolean'},
    //{label: 'Testo', fieldName: 'col11'}
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

const priceColumns = [
    {label: 'Prezzo', fieldName: 'col1'},
    {label: 'CP', fieldName: 'col2'},
    {label: 'Liv.prezzo', fieldName: 'col3'},
    {label: 'SM', fieldName: 'col4'},
    {label: 'UM', fieldName: 'col5'},
    {label: 'ClCal', fieldName: 'col6'},
    {label: 'BaseT', fieldName: 'col7'},
    {label: 'T', fieldName: 'col8'},
    {label: 'ClAdegPrz', fieldName: 'col9'},
    {label: 'M', fieldName: 'col10'},
    {label: 'PM', fieldName: 'col11'},
    {label: 'TA', fieldName: 'col12'},
    {label: 'A', fieldName: 'col13'},
    {label: 'TP', fieldName: 'col14'},
    {label: 'Data cr.', fieldName: 'col15'},
    {label: 'Creato da', fieldName: 'col16'}
];

const discountColumns = [
    {label: 'Sconto', fieldName: 'col1'},
    {label: 'Settore Merceologico', fieldName: 'col2'},
    {label: 'Tp Sconto', fieldName: 'col3'},
    {label: 'Base di Riferimento', fieldName: 'col4'},
    {label: 'Numeratore ammesso', fieldName: 'col5'},
    {label: 'Tipo Sconto ', fieldName: 'col6'},
    {label: 'Unità di misura', fieldName: 'col7'},
    {label: 'Base temp', fieldName: 'col8'},
    {label: 'Tipo Temp', fieldName: 'col9'},
    {label: 'Classe di Calcolo', fieldName: 'col10'},
    {label: 'Data creazione', fieldName: 'col11'},
    {label: 'Atuore', fieldName: 'col12'},
    {label: 'Data modifica', fieldName: 'col13'},
    {label: 'Autore modifica', fieldName: 'col14'},
    {label: 'Gruppo Autorizzazione', fieldName: 'col15'},
    {label: 'Codice Can.', fieldName: 'col16'}
];

const valueColumns = [
    {label: 'Valore', fieldName: 'col1'},
    {label: 'Field 1', fieldName: 'col2'},
    {label: 'Field 2', fieldName: 'col3'}
];

const stringValueColumns = [
    {label: 'Stringa', fieldName: 'col1'},
    {label: 'Field 1', fieldName: 'col2'},
    {label: 'Field 2', fieldName: 'col3'}
];

const rate = [
    {label: 'Id', fieldName: 'Id'},
    {label: 'Name', fieldName: 'Name'}
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
        switch (this.relatedToTable) {

            case 'FareTypeList__c':
                this.modalHeader = 'Seleziona la tariffa';
                this.columns = firstRow.concat(amountColumns);
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

        getTableData({objectApiName: this.fieldName})
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