import { LightningElement, api, track } from 'lwc';
import getContractRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getContractRecords';
import getMeterReadingRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getMeterReadingRecords';
//import getMeterReadingRecords from '@salesforce/apexContinuation/HDT_LC_AccountStatementController.getMeterReadingRecords';

export default class HdtMeterReading extends LightningElement {
    @api recordid;
    contractData = [];
    contractDataToView = [];
    @track contractColumns = contractColumns;
    @track detailTableHeader = 'Letture';
    @track accountData = [];
    @track meterReadingData;
    @track columns = columns;
    queryTerm = '';
    spinner = true;
    loadData = false;
    meterReadingError = false;
    meterReadingErrorMessage = '';

    error = false;
    errorMessage = '';

    connectedCallback() {
        this.contractBackendCall();
    }

    contractBackendCall(){
        getContractRecords({accountId: this.recordid}).then(result => {

            if(result.success){
                this.contractData = result.contractList;
                this.contractDataToView =  result.contractList;
                this.meterReadingBackendCall(this.contractData[0].contractNumber);
            } else {
                console.log('>>>> ERROR > getContractRecords');
                this.error = true;
                this.errorMessage = result.message;
                this.spinner = false;
            }

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(JSON.stringify(error));
        });
    }

    meterReadingBackendCall(contractNumber){
        console.log('>>>> contractNumber  > ' + contractNumber);
        getMeterReadingRecords({contractCode: contractNumber}).then(result => {

            if(result.success){
                this.meterReadingData = result.meterReadingList;
                this.detailTableHeader = 'Letture contratto > ' + contractNumber;
                this.loadData = true;
            } else {
                console.log('>>>> ERROR > getMeterReadingRecords');
                this.meterReadingError = true;
                this.meterReadingErrorMessage = result.message;
            }

            this.spinner = false;

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(JSON.stringify(error));
        });
    }

    handleRowAction(event) {
        console.log('# handleRowAction #');
        console.log(event.detail.row.contractNumber);
        this.detailTableHeader = 'Letture contratto > ' + event.detail.row.contractNumber;
        this.loadData = false;
        this.meterReadingError = false;
        this.meterReadingErrorMessage = '';
        this.meterReadingBackendCall(event.detail.row.contractNumber);
    }

    handleSearch(event) {
        this.contractDataToView = [];

        if(event.target.value!=''){
            var filteredContract = this.contractData.filter(c => { return c.contractNumber == event.target.value });

            if(filteredContract.length>0){
                this.contractDataToView = filteredContract;
            }
        } else {
            this.contractDataToView = this.contractData;
        }
    }

}

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

const contractColumns = [
    {
        label: '',
        type: 'button',
        initialWidth: 110,
        typeAttributes: {
                            label: 'Visualizza',
                            title: 'Seleziona',
                            variant: 'border-filled',
                            alternativeText: 'Seleziona'
                        }
    },
    {label: 'Numero Contratto', fieldName: 'contractNumber', initialWidth: 200},
    {label: 'Stato', fieldName: 'status'},
    {label: 'Data inizio', fieldName: 'startDate'},
    {label: 'Data fine', fieldName: 'endDate'},
    {label: 'Fornitura', fieldName: 'asset'},
    {label: 'Servizio', fieldName: 'service'}
];