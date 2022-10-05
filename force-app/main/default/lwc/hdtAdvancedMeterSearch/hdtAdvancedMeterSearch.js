
import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchMeterOnSap from '@salesforce/apex/HDT_LC_AdvancedMeterSearch.searchMeterOnSap';

const columns = [
    { label: 'Matricola', fieldName: 'matricola', type: 'text'},
    { label: 'Indirizzo', fieldName: 'indirizzo', type: 'text' },
    { label: 'Codice Punto', fieldName: 'puntoPresa', type: 'text' },
    { label: 'Stato Contratto', fieldName: 'statoContratto', type: 'text' },
    { label: 'Numero Contratto', fieldName: 'numeroContratto', type: 'text' },
    { label: 'Tipo Impianto', fieldName: 'tipoImpianto', type: 'text' }
];

export default class HdtAdvancedMeterSearch extends LightningElement {

    @api searchinputvalue;
    comune = '';
    silos = '';
    servizio = '';
    rowToSend;
    columns = columns;
    originalData;

    get serviceOptions() {
        return [
            { label: 'Acqua', value: 'Acqua' },
            { label: 'Energia Elettrica', value: 'Energia Elettrica' },
            { label: 'Gas', value: 'Gas' },
        ];
    }

    get silosOptions() {
        return [
            { label: 'AAA-EBT', value: 'AAA-EBT' },
            { label: 'HERA COMM', value: 'HERA COMM' },
            { label: 'MMS', value: 'MMS' },
            { label: 'Reseller', value: 'Reseller' },
        ];
    }

    //change value handlers

    handleChangeMatricola(event) {
        this.searchinputvalue = event.detail.value;
    }

    handleChangeService(event) {
        this.servizio = event.detail.value;
    }

    handleChangeSilos(event) {
        this.silos = event.detail.value;
    }

    handleChangeComune(event){
        this.comune = event.detail.value;
    }

    //handler chiamata al WS per ricerca matricola in SAP
    handleSapSearch(){

        if(!this.searchinputvalue || !this.servizio){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Errore!',
                message: 'Compilare i campi obbligatori prima di procedere con la ricerca in SAP.',
                variant: 'error'
            }));
        }else{

            searchMeterOnSap({matricola: this.searchinputvalue, servizio : this.servizio, comune : this.comune, silos : this.silos
            }).then(data => {
                if (data.length > 0) {
                    console.log('searchMeterOnSap - success');
                    console.log(JSON.stringify(data));
                    this.originalData = JSON.parse(data);
                }else{
                    console.log('searchMeterOnSap - success with empty data');
                }
            }).catch(error => {
                let errorMsg = error;
                if ('body' in error && 'message' in error.body) {
                    errorMsg = error.body.message
                }
                console.log('ERROR: ' + errorMsg);
            });
        }
    }

    connectedCallback(){}

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closemetersearch'));
    }

    getSelectedRow(event){
        let selectedRows = event.detail.selectedRows;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend*************************' + JSON.stringify(this.rowToSend));
    }

    handleConfirm(){
        if (this.rowToSend){
            let rowToSend = {'Codice Punto' : this.rowToSend['puntoPresa'], 'Servizio' : this.servizio};
            this.dispatchEvent(new CustomEvent('servicepointselectionmeter', {
                detail: rowToSend
            }));
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Errore!',
                message: 'Selezionare una riga prima di procedere con la conferma.',
                variant: 'error'
            }));
        }
    }
}