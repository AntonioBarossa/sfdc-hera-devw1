import { LightningElement, api, track, wire } from 'lwc';
import getMeterReadingRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getMeterReadingRecords';

const columns = [
    { label: 'Data lettura', fieldName: 'lectureDate', initialWidth: 150},
    { label: 'Fascia', fieldName: 'slot', initialWidth: 150},
    { label: 'Lettura (Interi)', fieldName: 'lectureInt', initialWidth: 150},
    { label: 'Lettura (Decimal)', fieldName: 'lectureDecimal', initialWidth: 150},
    { label: 'Consumo', fieldName: 'consumed', initialWidth: 150},
    { label: 'Codice Apparecchio', fieldName: 'assetCode', initialWidth: 150},
    { label: 'Codice Contratto', fieldName: 'contractCode', initialWidth: 150},
    { label: 'Stato', fieldName: 'status', initialWidth: 150},
    { label: 'Tipo lettura', fieldName: 'lectureType', initialWidth: 150},
    { label: 'Causale', fieldName: 'reason', initialWidth: 150},
    { label: 'Giorni di fatturazione', fieldName: 'billingDate', initialWidth: 150},
    { label: 'Consumo medio', fieldName: 'consumedAvg', initialWidth: 150},
    { label: 'Tipo registro', fieldName: 'regType', initialWidth: 150},
    { label: 'Consumo', fieldName: 'consumed', initialWidth: 150},
    { label: 'Unità di misura', fieldName: 'meters', initialWidth: 150},
    { label: 'Tipo di consumo', fieldName: 'consumedType', initialWidth: 150},
    { label: 'Settore merceologico', fieldName: 'sector', initialWidth: 150},
    { label: 'Flag lettura', fieldName: 'consumed', initialWidth: 150},
    { label: 'Motivazione', fieldName: 'reasonWhy', initialWidth: 150}
];

export default class HdtMeterReadingDetailTable extends LightningElement {

    @api contractNumber;
    @api loadData;
    @api hideCheckboxColumn;
    @track meterReadingData;
    @track detailTableHeader = 'Letture';
    @track columns = columns;
    meterReadingError = false;
    meterReadingErrorMessage = '';

    @api loadingData(){
        this.loadData = false;
        this.meterReadingError = false;
        this.meterReadingErrorMessage = '';
    }

    @wire(getMeterReadingRecords, {contractCode : '$contractNumber'})
    wiredRecords({ error, data }) {
        if(data) {
            if(data.success){
                this.meterReadingData = data.data;
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

    operation(){
        var selectedRow = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log(JSON.stringify(selectedRow));
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