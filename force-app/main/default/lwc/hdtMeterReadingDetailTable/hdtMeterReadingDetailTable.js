import { LightningElement, api, track, wire } from 'lwc';
import getMeterReadingRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getMeterReadingRecords';

export default class HdtMeterReadingDetailTable extends LightningElement {

    @api columnsobj;
    @api contractNumber;
    @api loadData;
    @api hideCheckboxColumn;
    @track meterReadingData;
    @track detailTableHeader = 'Letture';
    meterReadingError = false;
    meterReadingErrorMessage = '';

    connectedCallback(){
        console.log('HdtMeterReadingDetailTable loaded.');
    }

    @api loadingData(){
        this.loadData = false;
        this.meterReadingError = false;
        this.meterReadingErrorMessage = '';
    }

    @wire(getMeterReadingRecords, {contractCode : '$contractNumber'})
    wiredRecords({ error, data }) {
        if(data) {
            if(data.success){
                var obj = JSON.parse(data.data);
                this.meterReadingData = obj.data;
                this.detailTableHeader = 'Letture contratto > ' + this.contractNumber;
                this.loadData = true;
            } else {
                this.meterReadingError = true;
                this.meterReadingErrorMessage = data.message;
            }
            this.dataLoaded();
        } else if(error) {
            console.log('>>>> ERROR > getMeterReadingRecords');
            this.meterReadingError = true;
            this.meterReadingErrorMessage = 'ERROR';
        }
    }

    dataLoaded(){
        const dataLoad = new CustomEvent("dataload", {
            detail:  {spinner: false}
        });
        // Dispatches the event.
        this.dispatchEvent(dataLoad);
    }

    @api
    getSelectedReadingsValue() {
        var totalReadingValue = 0;
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        selectedRows.forEach(row => {
            const readingValue = parseInt(row.posizioniPrecedentiLaVirgola);
            totalReadingValue += (isNaN(readingValue) ? 0 : readingValue);
        });

        return totalReadingValue;
    }

    @api
    getSelectedReadingsList() {
        let selectedReadings = [];
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        selectedRows.forEach(row => {
            const readingValue = parseInt(row.posizioniPrecedentiLaVirgola);
            selectedReadings.push(isNaN(readingValue) ? 0 : readingValue);
        });

        return selectedReadings;
    }

    /*@api meterReadingBackendCall(contractNumber){
        console.log('>>>> contractNumber  > ' + contractNumber);
        this.loadData = false;
        getMeterReadingRecords({contractCode: contractNumber}).then(result => {

            if(result.success){
                this.meterReadingData = result.data;
                this.detailTableHeader = 'Letture contratto > ' + contractNumber;
                this.loadData = true;
            } else {
                console.log('>>>> ERROR > getMeterReadingRecords');
                this.meterReadingError = true;
                this.meterReadingErrorMessage = result.message;
            }

            const dataLoad = new CustomEvent("dataload", {
                detail:  {spinner: false}
            });
            // Dispatches the event.
            this.dispatchEvent(dataLoad);

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(JSON.stringify(error));
        });
    }*/

}