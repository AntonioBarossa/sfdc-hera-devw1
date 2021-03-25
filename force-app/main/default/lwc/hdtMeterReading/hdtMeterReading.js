import { LightningElement, api, track } from 'lwc';
import getContractRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getContractRecords';
//import getMeterReadingRecords from '@salesforce/apexContinuation/HDT_LC_AccountStatementController.getMeterReadingRecords';

export default class HdtMeterReading extends LightningElement {
    
    @api recordid;
    @track contractColumns = contractColumns;
    @track contractNumber;
    queryTerm = '';
    spinner = true;
    error = false;
    contractNumberAvailable = false;
    errorMessage = '';
    contractData = [];
    contractDataToView = [];

    connectedCallback() {
        this.contractBackendCall();
    }

    contractBackendCall(){
        getContractRecords({accountId: this.recordid}).then(result => {

            if(result.success){
                this.contractData = result.contractList;
                this.contractDataToView =  result.contractList;
                this.contractNumber = this.contractData[0].contractNumber;
                this.contractNumberAvailable = true;
                //this.template.querySelector("c-hdt-meter-reading-detail-table").meterReadingBackendCall(this.contractNumber);
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

    handleRowAction(event) {
        console.log('# handleRowAction #');
        console.log(event.detail.row.contractNumber);
        this.contractNumber = event.detail.row.contractNumber; 
        this.template.querySelector("c-hdt-meter-reading-detail-table").meterReadingBackendCall(this.contractNumber);
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

    dataload(event){
        this.spinner = event.detail.spinner;
    }

}

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