import { LightningElement, api, track } from 'lwc';
import getContractRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getContractRecords';
import getMeterReadingRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getMeterReadingRecords';
//import getMeterReadingRecords from '@salesforce/apexContinuation/HDT_LC_AccountStatementController.getMeterReadingRecords';

const contractData = [
    {
        Id: '1',
        contractNumber: '2001',
        status: 'Draft',
        startDate: '03/05/2018',
        endDate: '01/06/2020',
        asset: 'SP-0001',
        service: 'ELE'
    },
    {
        Id: '2',
        contractNumber: '2002',
        status: 'Draft',
        startDate: '02/02/2018',
        endDate: '02/05/2020',
        asset: 'SP-0001',
        service: 'GAS'
    }
];

export default class HdtMeterReading extends LightningElement {
    @api recordid;
    @track data = [];
    @track contractColumns = contractColumns;
    @track detailTableHeader = 'Letture';
    @track accountData = [];
    @track meterReadingData;
    @track columns = columns;
    spinner = true;

    connectedCallback() {
        this.contractBackendCall();
    }

    contractBackendCall(){
        getContractRecords({accountId: this.recordid}).then(result => {

            if(result.success){
                this.data = result.contractList;
                this.meterReadingBackendCall(this.data[0].contractNumber);
            } else {
                console.log('>>>> ERROR > getContractRecords');
                console.log(JSON.stringify(result));  
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
            } else {
                console.log('>>>> ERROR > getMeterReadingRecords');
                console.log(JSON.stringify(result));  
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
        this.meterReadingBackendCall(event.detail.row.contractNumber);
    }

    /*changeContractId(c){
        console.log('#### ' + c);
        var dataToView = [];
        var i;
        for(i=0; i<this.accountData.length; i++){
            if(this.accountData[i].contractId == c){
                dataToView.push(this.accountData[i]);
            }
        }
        this.meterReadingData = dataToView;
    }*/

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
    {label: 'Numero Contratto', fieldName: 'contractNumber'},
    {label: 'Stato', fieldName: 'status'},
    {label: 'Data inizio', fieldName: 'startDate'},
    {label: 'Data fine', fieldName: 'endDate'},
    {label: 'Fornitura', fieldName: 'asset'},
    {label: 'Servizio', fieldName: 'service'}
];